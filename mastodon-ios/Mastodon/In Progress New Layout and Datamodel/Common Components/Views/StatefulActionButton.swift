// Copyright © 2025 Mastodon gGmbH. All rights reserved.

import SwiftUI

enum AsyncBool {
    case unknown
    case fetching
    case isTrue
    case settingToTrue
    case isFalse
    case settingToFalse
    
    static func fromBool(_ value: Bool?) -> AsyncBool {
        guard let value else { return .unknown }
        if value {
            return .isTrue
        } else {
            return .isFalse
        }
    }
}

struct StatefulCountedActionButton: View {
    struct ActionState {
        let count: Int?
        let isSelected: AsyncBool
    }
    let type: PostAction
    let actionState: ActionState
    let doAction: (()->())?
    
    private let iconFont: Font = .body
    
    var body: some View {
        Button(action: { doAction?() }) {
            HStack(spacing: 4) {
                switch actionState.isSelected {
                case .isFalse, .isTrue:
                    Image(systemName: iconName)
                        .font(iconFont)
                case .fetching, .settingToFalse, .settingToTrue:
                    ProgressView()
                        .progressViewStyle(.circular)
                        .font(iconFont)
                case .unknown:
                    Image(systemName: "questionmark")
                        .font(iconFont)
                }
                ZStack(alignment: .leading) {
                    Text("0000")         // to keep the required space
                        .fontWeight(.semibold)
                        .hidden()
                    Text(countLabel ?? "")
                        .contentTransition(.numericText(value: Double(actionState.count ?? 0)))
                }
                .font(.footnote)
            }
            .fontWeight(actionState.isSelected == .isTrue ? .semibold : .regular)
            .foregroundStyle(color)
        }
        .buttonStyle(.borderless) // Without this, all the buttons in the row activate when one is tapped.  What a remarkably unexpected result with no documentation.
    }
    
    private var iconName: String {
        return type.systemIconName(filled: actionState.isSelected == .isTrue)
    }
    private var countLabel: String? {
        guard let count = actionState.count, count > 0 else { return nil }
        return count.formatted(.number.notation(.compactName))
    }
    private var color: Color {
        if actionState.isSelected == .isTrue {
            switch type {
            case .reply: return .secondary
            case .boost: return .green
            case .favourite: return .yellow
            case .bookmark: return .red
            }
        } else {
            return .secondary
        }
    }

}

