//
//  DataSourceFacade+SearchHistory.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-20.
//

import Foundation
import CoreDataStack
import MastodonCore
import UIKit

extension DataSourceFacade {

    static func responseToCreateSearchHistory(
        provider: UIViewController & AuthContextProvider,
        item: DataSourceItem
    ) async {
        switch item {
        case .account(account: let account, relationship: _):
            let now = Date()
            let userID = provider.authenticationBox.userID
            let searchEntry = Persistence.SearchHistory.Item(
                updatedAt: now,
                userID: userID,
                account: account,
                hashtag: nil
            )

            try? FileManager.default.addSearchItem(searchEntry, for: provider.authenticationBox)
        case .hashtag(let tag):

            let now = Date()
            let userID = provider.authenticationBox.userID
            let searchEntry = Persistence.SearchHistory.Item(
                updatedAt: now,
                userID: userID,
                account: nil,
                hashtag: tag
            )

            try? FileManager.default.addSearchItem(searchEntry, for: provider.authenticationBox)
        case .status, .notification, .notificationBanner(_):
                break

        }
    }
}
