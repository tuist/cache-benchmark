// Copyright © 2025 Mastodon gGmbH. All rights reserved.

import MastodonSDK
import MastodonCore
import Foundation

struct LastReadMarkers: Identifiable, Codable {
    enum MarkerPosition: Codable {
        case local(lastReadID: String)
        case fromServer(Mastodon.Entity.Marker.Position)
        
        var lastReadID: String {
            switch self {
            case .local(let lastReadID):
                return lastReadID
            case .fromServer(let position):
                return position.lastReadID
            }
        }
    }
    
    let userGUID: String
    let homeTimelineLastRead: MarkerPosition?
    let notificationsLastRead: MarkerPosition?
    let mentionsLastRead: MarkerPosition?
    
    var id: String {
        return userGUID
    }
    
    init(userGUID: String, home: MarkerPosition?, notifications: MarkerPosition?, mentions: MarkerPosition?) {
        self.userGUID = userGUID
        self.homeTimelineLastRead = home
        self.notificationsLastRead = notifications
        if let notifications, let mentions {
            if mentions.lastReadID > notifications.lastReadID {
                self.mentionsLastRead = mentions
            } else {
                self.mentionsLastRead = nil
            }
        } else {
            self.mentionsLastRead = mentions
        }
    }
    
    func lastRead(forKind kind: MastodonFeedKind) -> MarkerPosition? {
        switch kind {
        case .home:
            return homeTimelineLastRead
        case .notificationsAll:
            return notificationsLastRead
        case .notificationsMentionsOnly:
            return mentionsLastRead ?? notificationsLastRead
        case .notificationsWithAccount:
            return nil
        }
    }
    
    func bySettingPosition(_ newPosition: MarkerPosition, forKind kind: MastodonFeedKind, enforceForwardProgress: Bool) -> LastReadMarkers {
        if let previous = lastRead(forKind: kind) {
            guard !enforceForwardProgress || LastReadMarkers.id(previous.lastReadID, isOlderThan: newPosition.lastReadID) else { return self }
        }
        switch kind {
        case .home:
            return LastReadMarkers(userGUID: userGUID, home: newPosition, notifications: notificationsLastRead, mentions: mentionsLastRead)
        case .notificationsAll:
            return LastReadMarkers(userGUID: userGUID, home: homeTimelineLastRead, notifications: newPosition, mentions: mentionsLastRead)
        case .notificationsMentionsOnly:
            return LastReadMarkers(userGUID: userGUID, home: homeTimelineLastRead, notifications: notificationsLastRead, mentions: newPosition)
        case .notificationsWithAccount:
            return self
        }
    }
}

extension LastReadMarkers {
    static func id(_ thisId: String, isOlderThan otherId: String) -> Bool {
        if thisId.count == otherId.count {
            return thisId < otherId
        } else {
            return thisId.count < otherId.count
        }
    }
}
