// Copyright © 2023 Mastodon gGmbH. All rights reserved.

import Foundation
import MastodonCore
import MastodonSDK
import CoreDataStack

extension DataSourceFacade {
    public static func getEditHistory(
        forStatus status: Status,
        provider: AuthContextProvider
    ) async throws -> [Mastodon.Entity.StatusEdit] {
        let reponse = try await APIService.shared.getHistory(forStatusID: status.id, authenticationBox: provider.authenticationBox)

        return reponse.value
    }
}
