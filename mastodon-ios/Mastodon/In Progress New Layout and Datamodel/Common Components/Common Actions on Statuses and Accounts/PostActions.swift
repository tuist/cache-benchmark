// Copyright © 2025 Mastodon gGmbH. All rights reserved.

import SwiftUI

enum PostAction {
    case reply
    case boost
    case favourite
    case bookmark
    
    func systemIconName(filled: Bool) -> String {
        switch self {
        case .reply:
            return "arrow.turn.up.left"
        case .boost:
            return "arrow.2.squarepath"
        case .favourite:
            return filled ? "star.fill" : "star"
        case .bookmark:
            return filled ? "bookmark.fill" : "bookmark"
        }
    }
    
    var selectedColor: Color? {
        switch self {
        case .reply:
            return nil
        case .boost:
            return .green
        case .favourite:
            return .yellow
        case .bookmark:
            return .red
        }
    }
}
