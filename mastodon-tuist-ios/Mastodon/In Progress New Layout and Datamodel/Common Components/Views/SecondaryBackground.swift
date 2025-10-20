// Copyright © 2025 Mastodon gGmbH. All rights reserved.

import SwiftUI

struct MastodonSecondaryBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    let fillInDarkModeOnly: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                AnyShapeStyle(fillColor)
            )
            .stroke(.separator)
    }
    
    var fillColor: Color {
        if fillInDarkModeOnly && colorScheme != .dark {
            return .clear
        } else {
            return Color(UIColor.secondarySystemBackground)
        }
    }
}
