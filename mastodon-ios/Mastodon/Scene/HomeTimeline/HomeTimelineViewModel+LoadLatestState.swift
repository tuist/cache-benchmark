//
//  HomeTimelineViewModel+LoadLatestState.swift
//  Mastodon
//
//  Created by sxiaojian on 2021/2/5.
//

import func QuartzCore.CACurrentMediaTime
import Foundation
import CoreData
import CoreDataStack
import GameplayKit
import MastodonCore
import MastodonSDK

extension HomeTimelineViewModel {
    class LoadLatestState: GKState {
        
        let id = UUID()

        var name: String {
            String(describing: Self.self)
        }
        
        weak var viewModel: HomeTimelineViewModel?
        
        init(viewModel: HomeTimelineViewModel) {
            self.viewModel = viewModel
        }
        
        @MainActor
        func enter(state: LoadLatestState.Type) {
            stateMachine?.enter(state)
        }
    }
}

extension HomeTimelineViewModel.LoadLatestState {
    class Initial: HomeTimelineViewModel.LoadLatestState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Loading.self || stateClass == LoadingManually.self
        }
    }
    
    class Loading: HomeTimelineViewModel.LoadLatestState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Fail.self || stateClass == Idle.self
        }
        
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            loadLatest(viewModel: viewModel, isUserInitiated: false, isContextSwitch: previousState is HomeTimelineViewModel.LoadLatestState.ContextSwitch)
        }
    }
    
    class LoadingManually: HomeTimelineViewModel.LoadLatestState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Fail.self || stateClass == Idle.self
        }
        
        override func didEnter(from previousState: GKState?) {
            super.didEnter(from: previousState)
            loadLatest(viewModel: viewModel, isUserInitiated: true, isContextSwitch: previousState is HomeTimelineViewModel.LoadLatestState.ContextSwitch)
        }
    }
    
    class Fail: HomeTimelineViewModel.LoadLatestState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Loading.self || stateClass == Idle.self
        }
    }
    
    class Idle: HomeTimelineViewModel.LoadLatestState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Loading.self || stateClass == LoadingManually.self || stateClass == ContextSwitch.self
        }
    }

    class ContextSwitch: HomeTimelineViewModel.LoadLatestState {
        override func isValidNextState(_ stateClass: AnyClass) -> Bool {
            return stateClass == Loading.self || stateClass == LoadingManually.self  || stateClass == ContextSwitch.self
        }

        override func didEnter(from previousState: GKState?) {
            guard let viewModel else { return }
            Task { @MainActor in
                guard let diffableDataSource = viewModel.diffableDataSource else {
                    assertionFailure()
                    return
                }
                
                await viewModel.dataController.setRecordsAfterFiltering([])
                var snapshot = NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>()
                snapshot.appendSections([.main])
                snapshot.appendItems([.topLoader], toSection: .main)
                diffableDataSource.apply(snapshot) { [weak self] in
                    guard let self else { return }

                    self.stateMachine?.enter(Loading.self)
                }
            }
        }
    }

    private func loadLatest(viewModel: HomeTimelineViewModel?, isUserInitiated: Bool, isContextSwitch: Bool) {
        guard let viewModel else { return }
        
        Task { @MainActor in
            viewModel.timelineIsEmpty.send(nil)
            
            let latestFeedRecords = viewModel.dataController.records

            let latestStatusIDs: [Status.ID] = latestFeedRecords.compactMap { record in
                return record.status?.reblog?.id ?? record.status?.id
            }

            do {
                await AuthenticationServiceProvider.shared.fetchAccounts(onlyIfItHasBeenAwhile: true)
                let response: Mastodon.Response.Content<[Mastodon.Entity.Status]>
                
                /// To find out wether or not we need to show the "Load More" button
                /// we have make sure to eventually overlap with the most recent cached item
                let sinceID = latestFeedRecords.count > 1 ? latestFeedRecords[1].id : nil
                
                switch viewModel.timelineContext {
                case .home:
                    response = try await APIService.shared.homeTimeline(
                        itemsNoOlderThan: sinceID,
                        authenticationBox: viewModel.authenticationBox
                    )
                case .public:
                    response = try await APIService.shared.publicTimeline(
                        query: .init(local: true, sinceID: sinceID),
                        authenticationBox: viewModel.authenticationBox
                    )
                case let .list(id):
                    response = try await APIService.shared.listTimeline(
                        id: id,
                        query: .init(sinceID: sinceID),
                        authenticationBox: viewModel.authenticationBox
                    )
                case let .hashtag(tag):
                    response = try await APIService.shared.hashtagTimeline(
                        hashtag: tag,
                        authenticationBox: viewModel.authenticationBox
                    )
                }

                enter(state: Idle.self)
                viewModel.receiveLoadingStateCompletion(.finished)

                let statuses = response.value

                if statuses.isEmpty {
                    // stop refresher if no new statuses
                    await viewModel.dataController.setRecordsAfterFiltering([])
                    viewModel.didLoadLatest.send()
                } else {
                    var toAdd = [MastodonFeed]()
                    
                    let last = statuses.last
                    if let latestFirstId = latestFeedRecords.first?.id, let last, last.id == latestFirstId {
                        /// We have an overlap with the existing Statuses, thus no _Load More_ required
                        toAdd = statuses.prefix(statuses.count-1).map({ MastodonFeed.fromStatus($0.asMastodonStatus, kind: .home) })
                    } else {
                        /// If we do not have existing items, no _Load More_ is required as there is no gap
                        /// If our fetched Statuses do **not** overlap with the existing ones, we need a _Load More_ Button
                        toAdd = statuses.map({ MastodonFeed.fromStatus($0.asMastodonStatus, kind: .home) })
                        toAdd.last?.hasMore = latestFeedRecords.isNotEmpty
                    }
                    
                    let newRecords = (toAdd + latestFeedRecords).removingDuplicates()
                    await viewModel.dataController.setRecordsAfterFiltering(newRecords)
                }

                viewModel.timelineIsEmpty.value = (latestStatusIDs.isEmpty && statuses.isEmpty) ? {
                    switch viewModel.timelineContext {
                    case .home:
                        return .timeline
                    case .public:
                        return .timeline
                    case .list:
                        return .list
                    case .hashtag:
                        return .list
                    }
                }() : nil

                if !isUserInitiated {
                    FeedbackGenerator.shared.generate(.impact(.light))
                }
                
                let hasNewStatuses: Bool = {
                    if sinceID != nil {
                        return statuses.count > 1
                    }
                    return statuses.isNotEmpty
                }()
                
                if hasNewStatuses && !isContextSwitch {
                    viewModel.hasNewPosts.value = true
                }

            } catch {
                enter(state: Idle.self)
                viewModel.didLoadLatest.send()
                viewModel.receiveLoadingStateCompletion(.failure(error))
            }
        }   // end Task
    }
}
