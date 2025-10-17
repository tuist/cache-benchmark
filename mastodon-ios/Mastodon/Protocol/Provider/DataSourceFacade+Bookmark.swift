//
//  DataSourceFacade+Bookmark.swift
//  Mastodon
//
//  Created by ProtoLimit on 2022/07/29.
//

import UIKit
import CoreData
import CoreDataStack
import MastodonCore
import MastodonSDK

extension DataSourceFacade {
    @MainActor
    public static func responseToStatusBookmarkAction(
        provider: AuthContextProvider & DataSourceProvider,
        status: MastodonStatus
    ) async throws {
        FeedbackGenerator.shared.generate(.selectionChanged)
        
        let updatedStatus = try await APIService.shared.bookmark(
            record: status,
            authenticationBox: provider.authenticationBox
        ).value
        
        let newStatus: MastodonStatus = .fromEntity(updatedStatus)
        newStatus.showDespiteContentWarning = status.showDespiteContentWarning
        newStatus.showDespiteFilter = status.showDespiteFilter
        
        provider.update(contentStatus: newStatus, intent: .bookmark(updatedStatus.bookmarked == true))
    }
}
