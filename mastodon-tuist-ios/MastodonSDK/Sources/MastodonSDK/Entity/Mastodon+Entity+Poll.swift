//
//  Mastodon+Entity+Poll.swift
//  
//
//  Created by MainasuK Cirno on 2021/1/28.
//

import Foundation

extension Mastodon.Entity {
    /// Poll
    ///
    /// - Since: 2.8.0
    /// - Version: 3.3.0
    /// # Last Update
    ///   2021/2/24
    /// # Reference
    ///  [Document](https://docs.joinmastodon.org/entities/poll/)
    public struct Poll: Codable, Sendable, Hashable {
        public typealias ID = String
        
        public let id: ID
        
        /// if nil the poll does not end
        public let expiresAt: Date?
        
        public let expired: Bool
        
        /// Does the poll allow multiple-choice answers?/
        public let multiple: Bool
        
        /// How many votes have been received./
        public let votesCount: Int
        
        /// How many unique accounts have voted on a multiple-choice poll. nil if `multiple` is false
        public let votersCount: Int?
        
        /// When called with a user token, has the authorized user voted? nil if no current user.
        public let voted: Bool?
        
        /// When called with a user token, which options has the authorized user chosen? Contains an array of index values for options.  nil if no current user.
        public let ownVotes: [Int]?
        
        public let options: [Option]
        
        enum CodingKeys: String, CodingKey {
            case id
            case expiresAt = "expires_at"
            case expired
            case multiple
            case votesCount = "votes_count"
            case votersCount = "voters_count"
            case voted
            case ownVotes = "own_votes"
            case options
        }
    }
}

extension Mastodon.Entity.Poll {
    public struct Option: Codable, Sendable, Hashable {
        public let title: String
        /// nil if results are not published yet
        public let votesCount: Int?

        enum CodingKeys: String, CodingKey {
            case title
            case votesCount = "votes_count"
        }
    }
}
