//
//  DataSourceFacade+URL.swift
//  Mastodon
//
//  Created by Kyle Bashour on 11/24/22.
//

import Foundation
import CoreDataStack
import MetaTextKit
import MastodonCore
import MastodonSDK

extension DataSourceFacade {
    static func responseToURLAction(
        provider: DataSourceProvider & AuthContextProvider,
        url: URL
    ) async {
        guard let coordinator = await provider.sceneCoordinator else { return }
        let domain = provider.authenticationBox.domain
        if url.host == domain,
           url.pathComponents.count >= 4,
           url.pathComponents[0] == "/",
           url.pathComponents[1] == "web",
           url.pathComponents[2] == "statuses" {
            let statusID = url.pathComponents[3]
            let threadViewModel = await RemoteThreadViewModel(authenticationBox: provider.authenticationBox, statusID: statusID)
            _ = await coordinator.present(scene: .thread(viewModel: threadViewModel), from: nil, transition: .show)
        } else {
            _ = await coordinator.present(scene: .safari(url: url), from: nil, transition: .safariPresent(animated: true, completion: nil))
        }
    }
}
