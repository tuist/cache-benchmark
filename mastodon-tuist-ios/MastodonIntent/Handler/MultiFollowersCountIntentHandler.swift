// Copyright © 2023 Mastodon gGmbH. All rights reserved.

import Foundation
import Intents
import MastodonCore
import MastodonSDK
import MastodonLocalization

@MainActor
class MultiFollowersCountIntentHandler: INExtension, MultiFollowersCountIntentHandling {
    func provideAccountsOptionsCollection(for intent: MultiFollowersCountIntent, searchTerm: String?) async throws -> INObjectCollection<NSString> {
        guard
            let searchTerm = searchTerm,
            let authenticationBox = AuthenticationServiceProvider.shared.currentActiveUser.value
        else {
            return INObjectCollection(items: [])
        }

        let results = try await APIService.shared
            .search(query: .init(q: searchTerm), authenticationBox: authenticationBox)
        
        return INObjectCollection(items: results.value.accounts.map { $0.acctWithDomainIfMissing(authenticationBox.domain) as NSString })
    }
}
