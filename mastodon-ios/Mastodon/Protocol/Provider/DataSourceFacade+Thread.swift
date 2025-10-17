//
//  DataSourceFacade+Thread.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-17.
//

import UIKit
import CoreData
import CoreDataStack
import MastodonCore
import MastodonSDK

extension DataSourceFacade {
    static func coordinateToStatusThreadScene(
        provider: UIViewController,
        target: StatusTarget,
        status: MastodonStatus
    ) async {
        let _root: MastodonItemIdentifier.Thread? = {
            let redirectRecord = DataSourceFacade.status(
                status: status,
                target: target
            )
            
            let threadContext = MastodonItemIdentifier.Thread.Context(status: redirectRecord)
            return MastodonItemIdentifier.Thread.root(context: threadContext)
        }()
        guard let root = _root else {
            assertionFailure()
            return
        }
        
        await coordinateToStatusThreadScene(
            provider: provider,
            root: root
        )
    }
    
    @MainActor
    static func coordinateToStatusThreadScene(
        provider: UIViewController,
        root: MastodonItemIdentifier.Thread
    ) async {
        guard let authBox = AuthenticationServiceProvider.shared.currentActiveUser.value else { return }
        let threadViewModel = ThreadViewModel(
            authenticationBox: authBox,
            optionalRoot: root
        )
        guard let coordinator = provider.sceneCoordinator else { return }
        _ = coordinator.present(
            scene: .thread(viewModel: threadViewModel),
            from: provider,
            transition: .show
        )
    }
}
