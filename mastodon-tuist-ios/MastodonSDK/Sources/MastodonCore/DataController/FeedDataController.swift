import Foundation
import UIKit
import Combine
import MastodonSDK
import os.log

//@available(*, deprecated, message: "migrate to MastodonFeedLoader")
@MainActor
final public class FeedDataController {
    private let logger = Logger(subsystem: "FeedDataController", category: "Data")
    private static let entryNotFoundMessage = "Failed to find suitable record. Depending on the context this might result in errors (data not being updated) or can be discarded (e.g. when there are mixed data sources where an entry might or might not exist)."

    @Published public private(set) var records: [MastodonFeed] = []
    
    private let authenticationBox: MastodonAuthenticationBox
    private let kind: MastodonFeed.Kind
    
    private var subscriptions = Set<AnyCancellable>()
    
    public init(authenticationBox: MastodonAuthenticationBox, kind: MastodonFeed.Kind) {
        self.authenticationBox = authenticationBox
        self.kind = kind
        
        StatusFilterService.shared.$activeFilterBox
            .sink { filterBox in
                if filterBox != nil {
                    Task { [weak self] in
                        guard let self else { return }
                        await self.setRecordsAfterFiltering(self.records)
                    }
                }
            }
            .store(in: &subscriptions)
    }
    
    public func setRecordsAfterFiltering(_ newRecords: [MastodonFeed]) async {
        guard let filterBox = StatusFilterService.shared.activeFilterBox else { self.records = newRecords; return }
        let filtered = await self.filter(newRecords, forFeed: kind, with: filterBox)
        self.records = filtered.removingDuplicates()
    }
    
    public func appendRecordsAfterFiltering(_ additionalRecords: [MastodonFeed]) async {
        guard let filterBox = StatusFilterService.shared.activeFilterBox else { self.records += additionalRecords; return }
        let newRecords = await self.filter(additionalRecords, forFeed: kind, with: filterBox)
        self.records = (self.records + newRecords).removingDuplicates()
    }
    
    public func loadInitial(kind: MastodonFeed.Kind) {
        Task {
            let unfilteredRecords = try await load(kind: kind, maxID: nil)
            await setRecordsAfterFiltering(unfilteredRecords)
        }
    }
    
    public func loadNext(kind: MastodonFeed.Kind) {
        Task {
            guard let lastId = records.last?.status?.id else {
                return loadInitial(kind: kind)
            }

            let unfiltered = try await load(kind: kind, maxID: lastId)
            await self.appendRecordsAfterFiltering(unfiltered)
        }
    }
    
    private func filter(_ records: [MastodonFeed], forFeed feedKind: MastodonFeed.Kind, with filterBox: Mastodon.Entity.FilterBox) async -> [MastodonFeed] {
        
        let filteredRecords = records.filter { feedRecord in
            guard let status = feedRecord.status else { return true }
            let filterResult = filterBox.apply(to: status, in: feedKind.filterContext)
            switch filterResult {
            case .hide:
                return false
            default:
                return true
            }
        }
        return filteredRecords
    }
    
    @MainActor
    public func update(status: MastodonStatus, intent: MastodonStatus.UpdateIntent) {
        switch intent {
        case .delete:
            delete(status)
        case .edit:
            updateEdited(status)
        case let .bookmark(isBookmarked):
            updateBookmarked(status, isBookmarked)
        case let .favorite(isFavorited):
            updateFavorited(status, isFavorited)
        case let .reblog(isReblogged):
            updateReblogged(status, isReblogged)
        case let .toggleSensitive(isVisible):
            updateSensitive(status, isVisible)
        case .pollVote:
            updateEdited(status) // technically the data changed so refresh it to reflect the new data
        }
    }
    
    @MainActor
    private func delete(_ status: MastodonStatus) {
        records.removeAll { $0.id == status.id }
    }
    
    @MainActor
    private func updateEdited(_ status: MastodonStatus) {
        var newRecords = Array(records)
        guard let index = newRecords.firstIndex(where: { $0.id == status.id }) else {
            logger.warning("\(Self.entryNotFoundMessage)")
            return
        }
        let existingRecord = newRecords[index]
        let newStatus = status.inheritSensitivityToggled(from: existingRecord.status)
        newRecords[index] = .fromStatus(newStatus, kind: existingRecord.kind)
        records = newRecords
    }
    
    @MainActor
    private func updateBookmarked(_ status: MastodonStatus, _ isBookmarked: Bool) {
        var newRecords = Array(records)
        
        let relevant = recordsContaining(statusID: status.id)
        Task {
            let refetched = await refetchStatuses(relevant)
            
            for record in refetched {
                if let idx = newRecords.firstIndex(where: { $0.id == record.id }) {
                    let existingRecord = newRecords[idx]
                    newRecords[idx] = .fromStatus(MastodonStatus(entity: record, showDespiteContentWarning: existingRecord.status?.showDespiteContentWarning ?? false), kind: existingRecord.kind)
                } else {
                    logger.warning("\(Self.entryNotFoundMessage)")
                    return
                }
            }
            records = newRecords
        }
    }
    
    @MainActor
    private func updateFavorited(_ status: MastodonStatus, _ isFavorited: Bool) {
        var newRecords = Array(records)
        let relevant = recordsContaining(statusID: status.id)
        Task {
            let refetched = await refetchStatuses(relevant)
            
            for record in refetched {
                if let idx = newRecords.firstIndex(where: { $0.id == record.id }) {
                    let existingRecord = newRecords[idx]
                    newRecords[idx] = .fromStatus(MastodonStatus(entity: record, showDespiteContentWarning: existingRecord.status?.showDespiteContentWarning ?? false), kind: existingRecord.kind)
                } else {
                    logger.warning("\(Self.entryNotFoundMessage)")
                    return
                }
            }
            records = newRecords
        }
    }
    
    @MainActor
    private func updateReblogged(_ status: MastodonStatus, _ isReblogged: Bool) {
        var newRecords = Array(records)
        let relevantID = isReblogged ? (status.reblog?.id ?? status.id) : status.id
        let relevant = recordsContaining(statusID: relevantID)
        Task {
            let refetched = await refetchStatuses(relevant)
//            print("found \(refetched.count) relevant statuses for \(status.id)")
            
            for record in refetched {
                if let idx = newRecords.firstIndex(where: { $0.id == record.id }) {
                    let existingRecord = newRecords[idx]
//                    print("replacing record for \(existingRecord.status?.id) (reblog of \(existingRecord.status?.reblog))...")
//                    if existingRecord.status?.entity.reblogged == true || existingRecord.status?.reblog?.entity.reblogged == true {
//                        print("- was reblogged by me")
//                    } else {
//                        print("- NOT reblogged by me")
//                    }
                    let newRecord = MastodonFeed.fromStatus(MastodonStatus(entity: record, showDespiteContentWarning: existingRecord.status?.showDespiteContentWarning ?? false), kind: existingRecord.kind)
                    newRecords[idx] = newRecord
//                    print("replaced with \(newRecord.status?.id) (reblog of \(newRecord.status?.reblog?.id))")
//                    if newRecord.status?.entity.reblogged == true || newRecord.status?.reblog?.entity.reblogged == true {
//                        print("- was reblogged by me")
//                    } else {
//                        print("- NOT reblogged by me")
//                    }
                } else if !isReblogged, let idx = newRecords.firstIndex(where: { let contentID = $0.status?.reblog?.id
                    return contentID == record.id }) {
                    // possible this is the now-deleted record of my own reblog action
                    // if so, replace it with the unboosted version
                    let existingRecord = newRecords[idx]
                    if existingRecord.status?.entity.account.acct == authenticationBox.cachedAccount?.acct {
                        let sensitivityUpdated = status.inheritSensitivityToggled(from: existingRecord.status?.reblog)
                        newRecords[idx] = MastodonFeed.fromStatus(sensitivityUpdated, kind: existingRecord.kind)
                    }
                } else {
                    logger.warning("\(Self.entryNotFoundMessage)")
                    return
                }
            }
            records = newRecords
        }
    }
    
    @MainActor
    private func updateSensitive(_ status: MastodonStatus, _ isVisible: Bool) {
        let toUpdate = recordsContaining(statusID: status.id)
        var newRecords = Array(records)
        for record in toUpdate {
            if let index = newRecords.firstIndex(where: { $0.status?.id == record.id }), let existingEntity = newRecords[index].status?.entity {
                if existingEntity.id == status.id {
                    let existingRecord = newRecords[index]
                    let newStatus: MastodonStatus = .fromEntity(existingEntity)
                    newStatus.reblog = status
                    newRecords[index] = .fromStatus(newStatus, kind: existingRecord.kind)
                } else if existingEntity.reblog?.id == status.id {
                    let existingRecord = newRecords[index]
                    let newStatus: MastodonStatus = .fromEntity(existingEntity)
                        .inheritSensitivityToggled(from: status)
                    newRecords[index] = .fromStatus(newStatus, kind: existingRecord.kind)
                } else {
                    logger.warning("\(Self.entryNotFoundMessage)")
                    return
                }
            }
        }
        records = newRecords
    }
    
    @MainActor
    private func recordsContaining(statusID: Mastodon.Entity.Status.ID) -> [MastodonFeed] {
        records.filter { feed in
            return feed.status?.id == statusID || feed.status?.reblog?.id == statusID
        }
    }
    
    @MainActor
    private func refetchStatuses(_ items: [MastodonFeed]) async -> [Mastodon.Entity.Status] {
        
        switch kind {
        case .notificationAll, .notificationMentions, .notificationAccount:
            return []
        default:
            var refetched = [Mastodon.Entity.Status]()
            for item in items {
                do {
                    let refetchedItem = try await APIService.shared.status(statusID: item.id, authenticationBox: authenticationBox)
                    refetched.append(refetchedItem.value)
                } catch {
                    if let contentItemID = item.status?.reblog?.id {
                        if let refetchedContentItem = try? await APIService.shared.status(statusID: contentItemID, authenticationBox: authenticationBox) {
                            refetched.append(refetchedContentItem.value)
                        }
                    }
                }
            }
            return refetched
        }
    }
}

private extension FeedDataController {

    func load(kind: MastodonFeed.Kind, maxID: MastodonStatus.ID?) async throws -> [MastodonFeed] {
        switch kind {
        case .home(let timeline):
            await AuthenticationServiceProvider.shared.fetchAccounts(onlyIfItHasBeenAwhile: true)

            let response: Mastodon.Response.Content<[Mastodon.Entity.Status]>

            switch timeline {
            case .home:
                response = try await APIService.shared.homeTimeline(
                    itemsImmediatelyBefore: maxID,
                    authenticationBox: authenticationBox
                )
            case .public:
                response = try await APIService.shared.publicTimeline(
                    query: .init(local: true, maxID: maxID),
                    authenticationBox: authenticationBox
                )
            case let .list(id):
                response = try await APIService.shared.listTimeline(
                    id: id,
                    query: .init(maxID: maxID),
                    authenticationBox: authenticationBox
                )
            case let .hashtag(tag):
                response = try await APIService.shared.hashtagTimeline(
                    hashtag: tag,
                    authenticationBox: authenticationBox
                )
            }

            return response.value.compactMap { entity in
                let status = MastodonStatus.fromEntity(entity)
                return .fromStatus(status, kind: .home)
            }
        case .notificationAll:
            return try await getFeeds(with: .everything)
        case .notificationMentions:
            return try await getFeeds(with: .mentions)
        case .notificationAccount(let accountID):
            return try await getFeeds(with: nil, accountID: accountID)
        }
    }

    private func getFeeds(with scope: APIService.MastodonNotificationScope?, accountID: String? = nil) async throws -> [MastodonFeed] {

        let notifications = try await APIService.shared.notifications(olderThan: nil, fromAccount: accountID, scope: scope, authenticationBox: authenticationBox).value

        let accounts = notifications.map { $0.account }
        let relationships = try await APIService.shared.relationship(forAccounts: accounts, authenticationBox: authenticationBox).value

        let notificationsWithRelationship: [(notification: Mastodon.Entity.Notification, relationship: Mastodon.Entity.Relationship?)] = notifications.compactMap { notification in
            guard let relationship = relationships.first(where: {$0.id == notification.account.id }) else { return (notification: notification, relationship: nil)}

            return (notification: notification, relationship: relationship)
        }

        let feeds = notificationsWithRelationship.compactMap({ (notification: Mastodon.Entity.Notification, relationship: Mastodon.Entity.Relationship?) in
            MastodonFeed.fromNotification(notification, relationship: relationship, kind: .notificationAll)
        })

        return feeds
    }
}

extension MastodonFeed.Kind {
    var filterContext: Mastodon.Entity.FilterContext {
        switch self {
        case .home(let timeline): // TODO: take timeline into account. See iOS-333.
            return .home
        case .notificationAccount, .notificationAll, .notificationMentions:
            return .notifications
        }
    }
}
