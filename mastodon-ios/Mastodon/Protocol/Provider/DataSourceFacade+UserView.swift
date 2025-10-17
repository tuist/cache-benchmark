// Copyright © 2023 Mastodon gGmbH. All rights reserved.

import Foundation
import MastodonUI
import CoreDataStack
import MastodonCore
import MastodonSDK
import UIKit

extension DataSourceFacade {
    static func responseToUserViewButtonAction(
        dependency: UIViewController & AuthContextProvider,
        account: Mastodon.Entity.Account,
        buttonState: UserView.ButtonState
    ) async throws -> Mastodon.Entity.Relationship? {
        switch buttonState {
            case .follow, .request, .unfollow, .blocked, .pending:
                return try await DataSourceFacade.responseToUserFollowAction(
                    dependency: dependency,
                    account: account
                )
            case .none, .loading:
                return nil
        }
    }
}
