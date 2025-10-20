//
//  DataSourceFacade+Mute.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-24.
//

import UIKit
import MastodonSDK
import MastodonCore

extension DataSourceFacade {
    static func responseToUserMuteAction(
        dependency: AuthContextProvider,
        account: Mastodon.Entity.Account
    ) async throws -> Mastodon.Entity.Relationship {
        FeedbackGenerator.shared.generate(.selectionChanged)

        let response = try await APIService.shared.toggleMute(
            authenticationBox: dependency.authenticationBox,
            account: account
        )

        let userInfo = [
            UserInfoKey.relationship: response.value,
        ]

        NotificationCenter.default.post(name: .relationshipChanged, object: self, userInfo: userInfo)

        return response.value
    }
}
