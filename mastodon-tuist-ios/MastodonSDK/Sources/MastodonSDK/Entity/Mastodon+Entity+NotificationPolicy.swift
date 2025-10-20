// Copyright © 2024 Mastodon gGmbH. All rights reserved.

import Foundation

extension Mastodon.Entity {
    public struct NotificationPolicy: Codable, Hashable {
        public let forNotFollowing: NotificationFilterAction
        public let forNotFollowers: NotificationFilterAction
        public let forNewAccounts: NotificationFilterAction
        public let forPrivateMentions: NotificationFilterAction
        public let forLimitedAccounts: NotificationFilterAction
        public let summary: Summary
        
        enum CodingKeys: String, CodingKey {
            case forNotFollowing = "for_not_following"
            case forNotFollowers = "for_not_followers"
            case forNewAccounts = "for_new_accounts"
            case forPrivateMentions = "for_private_mentions"
            case forLimitedAccounts = "for_limited_accounts"
            case summary
        }
        
        public struct Summary: Codable, Hashable {
            public let pendingRequestsCount: Int
            public let pendingNotificationsCount: Int
            
            enum CodingKeys: String, CodingKey {
                case pendingRequestsCount = "pending_requests_count"
                case pendingNotificationsCount = "pending_notifications_count"
            }
        }
        
        public enum NotificationFilterAction: RawRepresentable, Codable, Sendable, Equatable, Hashable {
            public typealias RawValue = String
            
            case accept
            case filter
            case drop
            case _other(String)
            
            public init?(rawValue: String) {
                switch rawValue {
                case "accept":  self = .accept
                case "filter":  self = .filter
                case "drop":    self = .drop
                default:        self = ._other(rawValue)
                }
            }
            
            public var rawValue: RawValue {
                switch self {
                case .accept:               return "accept"
                case .filter:               return "filter"
                case .drop:                 return "drop"
                case ._other(let string):   return string
                }
            }
        }
    }
}
