//
//  DataSourceFacade+Favorite.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-21.
//

import UIKit
import CoreData
import MastodonSDK
import MastodonCore

extension DataSourceFacade {
    @MainActor
    public static func responseToStatusFavoriteAction(
        provider: DataSourceProvider & AuthContextProvider,
        wrappingStatus: MastodonStatus,
        contentStatus: MastodonStatus
    ) async throws {
        FeedbackGenerator.shared.generate(.selectionChanged)

        let updatedStatus = try await APIService.shared.favorite(
            status: contentStatus,
            authenticationBox: provider.authenticationBox
        ).value
        
        let showDespiteContentWarning = wrappingStatus.showDespiteContentWarning
        let showDespiteFilter = wrappingStatus.showDespiteFilter
        
        let newStatus: MastodonStatus = .fromEntity(updatedStatus)
        newStatus.showDespiteContentWarning = showDespiteContentWarning
        newStatus.showDespiteFilter = showDespiteFilter
        
        provider.update(contentStatus: newStatus, intent: .favorite(updatedStatus.favourited == true))
    }
}
