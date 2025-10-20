//
//  DataSourceFacade+Reblog.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-21.
//

import UIKit
import MastodonCore
import MastodonUI
import MastodonSDK
import MastodonLocalization

extension DataSourceFacade {
    @MainActor
    static func responseToStatusReblogAction(
        provider: DataSourceProvider & AuthContextProvider,
        wrappingStatus: MastodonStatus,
        contentStatus: MastodonStatus
    ) async throws {
        if UserDefaults.shared.askBeforeBoostingAPost {
            let alertController = UIAlertController(
                title: contentStatus.entity.reblogged == true ? L10n.Common.Alerts.BoostAPost.titleUnboost : L10n.Common.Alerts.BoostAPost.titleBoost,
                message: nil,
                preferredStyle: .alert
            )
            let cancelAction = UIAlertAction(title: L10n.Common.Alerts.BoostAPost.cancel, style: .default)
            alertController.addAction(cancelAction)
            let confirmAction = UIAlertAction(
                title: contentStatus.entity.reblogged == true ? L10n.Common.Alerts.BoostAPost.unboost : L10n.Common.Alerts.BoostAPost.boost,
                style: .default
            ) { _ in
                Task { @MainActor in
                    try? await performReblog(provider: provider, status: contentStatus)
                }
            }
            alertController.addAction(confirmAction)
            provider.present(alertController, animated: true)
        } else {
            try await performReblog(provider: provider, status: contentStatus)
        }
    }
}

private extension DataSourceFacade {
    @MainActor
    static func performReblog(
        provider: DataSourceProvider & AuthContextProvider,
        status: MastodonStatus
    ) async throws {
        FeedbackGenerator.shared.generate(.selectionChanged)

        let updatedContentStatus = try await APIService.shared.reblog(
            status: status,
            authenticationBox: provider.authenticationBox
        ).value

        let newStatus: MastodonStatus = .fromEntity(updatedContentStatus)
        newStatus.reblog?.showDespiteContentWarning = status.showDespiteContentWarning
        newStatus.reblog?.showDespiteFilter = status.showDespiteFilter
        newStatus.showDespiteContentWarning = status.showDespiteContentWarning
        newStatus.showDespiteFilter = status.showDespiteFilter
        
        provider.update(contentStatus: newStatus, intent: .reblog(updatedContentStatus.reblogged == true))
    }
}
