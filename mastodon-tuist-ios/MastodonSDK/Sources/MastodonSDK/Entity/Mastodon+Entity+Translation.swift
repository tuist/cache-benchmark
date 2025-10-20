//
//  Mastodon+Entity+Translation.swift
//  
//
//  Created by Marcus Kida on 02.12.22.
//

import Foundation

extension Mastodon.Entity {
    public struct Translation: Codable, Sendable {
        public let content: String?
        public let sourceLanguage: String?
        public let provider: String?
        public let spoilerText: String?
        public let poll: Poll?
        public let mediaAttachments: [Attachment]?
        
        enum CodingKeys: String, CodingKey {
            case content
            case sourceLanguage = "detected_source_language"
            case provider
            case spoilerText = "spoiler_text"
            case poll
            case mediaAttachments = "media_attachments"
        }
        
        public struct Poll: Codable, Sendable {
            public let id: String
            public let options: [Option]
            
            public struct Option: Codable, Sendable {
                public let title: String
            }
        }
        
        public struct Attachment: Codable, Sendable {
            public let id: String
            public let description: String
        }
    }
}
