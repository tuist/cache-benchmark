//
//  DataSourceFacade+Block.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-24.
//

import UIKit
import CoreDataStack
import MastodonCore
import MastodonSDK

extension DataSourceFacade {
    static func responseToUserBlockAction(
        dependency: AuthContextProvider,
        account: Mastodon.Entity.Account
    ) async throws -> Mastodon.Entity.Relationship {
        FeedbackGenerator.shared.generate(.selectionChanged)

        let apiService = APIService.shared
        let authBox = dependency.authenticationBox

        let response = try await apiService.toggleBlock(
            account: account,
            authenticationBox: authBox
        )

        let userInfo = [
            UserInfoKey.relationship: response.value,
        ]

        NotificationCenter.default.post(name: .relationshipChanged, object: self, userInfo: userInfo)

        return response.value
    }

    static func responseToDomainBlockAction(
        dependency: AuthContextProvider,
        account: Mastodon.Entity.Account
    ) async throws -> Mastodon.Entity.Empty {
        FeedbackGenerator.shared.generate(.selectionChanged)

        let apiService = APIService.shared
        let authBox = dependency.authenticationBox

        let response = try await apiService.toggleDomainBlock(account: account, authenticationBox: authBox)

        return response.value
    }
}
