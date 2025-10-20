//
//  Mastodon+Entity+ServerFilterResult.swift
//  MastodonSDK
//
//  Created by Shannon Hughes on 3/27/25.
//


import Foundation

extension Mastodon.Entity {
    /// ServerFilterResult
    ///
    /// - Since: 4.0.0
    /// - Version: 4.0.0
    /// # Last Update
    ///   2025.03.27
    /// # Reference
    ///  [Document](https://docs.joinmastodon.org/entities/FilterResult/)
    public struct ServerFilterResult: Codable, Sendable {
        public let filter: Mastodon.Entity.FilterV2 //  The filter that was matched.
        public let keywordMatches: [String]?  // The keyword within the filter that was matched.
        public let statusMatches: [Mastodon.Entity.Status.ID]? // The status ID within the filter that was matched.
        
        enum CodingKeys: String, CodingKey {
            case filter
            case keywordMatches = "keyword_matches"
            case statusMatches = "status_matches"
        }
        
    }
}
