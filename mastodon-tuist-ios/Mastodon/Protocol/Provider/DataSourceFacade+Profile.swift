//
//  DataSourceFacade+Profile.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-13.
//

import UIKit
import CoreDataStack
import MastodonCore
import MastodonSDK

extension DataSourceFacade {
    
    @MainActor
    static func coordinateToProfileScene(
        provider: DataSourceProvider & AuthContextProvider,
        target: StatusTarget,
        status: MastodonStatus
    ) async {
        let acct: String
        switch target {
        case .status:
            acct = status.reblog?.entity.account.acct ?? status.entity.account.acct
        case .reblog:
            acct = status.entity.account.acct
        }
        
        guard let coordinator = provider.sceneCoordinator else { return }
        
        coordinator.showLoading()
        
        let _redirectRecord = try? await Mastodon.API.Account.lookupAccount(
            session: .shared,
            domain: provider.authenticationBox.domain,
            query: .init(acct: acct),
            authorization: provider.authenticationBox.userAuthorization
        ).singleOutput().value
        
        coordinator.hideLoading()
                
        guard let redirectRecord = _redirectRecord else {
            // Note: this situation arises if your account has been suspended, among other possibilities
            assertionFailure()
            return
        }

        await coordinateToProfileScene(
            provider: provider,
            account: redirectRecord
        )
    }

    @MainActor
    static func coordinateToProfileScene(
        provider: UIViewController & AuthContextProvider,
        username: String,
        domain: String
    ) async {
        guard let coordinator = provider.sceneCoordinator else { return }
        
        coordinator.showLoading()

        do {
            guard let account = try await APIService.shared.fetchNotMeUser( // ProfileViewController will fetch credentialed user later if this is actually me
                username: username,
                domain: domain,
                authenticationBox: provider.authenticationBox
            ) else {
                return coordinator.hideLoading()
            }

            coordinator.hideLoading()

            await coordinateToProfileScene(provider: provider, account: account)
        } catch {
            coordinator.hideLoading()
        }
    }

    @MainActor
    static func coordinateToProfileScene(
        provider: UIViewController & AuthContextProvider,
        domain: String,
        accountID: String
    ) async {
        guard let coordinator = provider.sceneCoordinator else { return }
        
        coordinator.showLoading()

            do {
                let account = try await APIService.shared.accountInfo(
                    domain: domain,
                    userID:
                        accountID,
                    authorization: provider.authenticationBox.userAuthorization
                )

                coordinator.hideLoading()

                await coordinateToProfileScene(provider: provider, account: account)
            } catch {
                coordinator.hideLoading()
        }
    }

    @MainActor
    public static func coordinateToProfileScene(
        provider: UIViewController & AuthContextProvider,
        account: Mastodon.Entity.Account
    ) async {
        guard let coordinator = provider.sceneCoordinator else { return }
        coordinator.showLoading()
        defer { coordinator.hideLoading() }

        guard let me = provider.authenticationBox.cachedAccount else { return }

        let profileType: ProfileViewController.ProfileType
        if me == account {
            profileType = .me(me)
        } else {
            guard let relationship = try? await APIService.shared.relationship(forAccounts: [account], authenticationBox: provider.authenticationBox).value.first else {
                return
            }
            profileType = .notMe(me: me, displayAccount: account, relationship: relationship)
        }
        
        _ = coordinator.present(
            scene: .profile(profileType),
            from: provider,
            transition: .show
        )
    }
}

extension DataSourceFacade {

    @MainActor
    static func coordinateToProfileScene(
        provider: DataSourceProvider & AuthContextProvider,
        status: MastodonStatus,
        mention: String,        // username,
        userInfo: [AnyHashable: Any]?
    ) async {
        let domain = provider.authenticationBox.domain
        
        guard
            let href = userInfo?["href"] as? String,
            let url = URL(string: href)
        else {
            return
        }
        let mentions = status.entity.mentions

        guard let coordinator = provider.sceneCoordinator else { return }
        guard let mention = mentions.first(where: { $0.url == href }) else {
            _ = coordinator.present(
                scene: .safari(url: url),
                from: provider,
                transition: .safariPresent(animated: true, completion: nil)
            )
            return
        }

        await DataSourceFacade.coordinateToProfileScene(provider: provider, domain: domain, accountID: mention.id)
    }

}

extension DataSourceFacade {
    static func createActivityViewController(
        dependency: UIViewController,
        account: Mastodon.Entity.Account
    ) -> UIActivityViewController {

        let activityViewController = UIActivityViewController(
            activityItems: [account.url],
            applicationActivities: [SafariActivity(sceneCoordinator: dependency.sceneCoordinator)]
        )
        return activityViewController
    }
    
    static func createActivityViewControllerForMastodonUser(status: Status, dependency: UIViewController) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(
            activityItems: status.activityItems,
            applicationActivities: [SafariActivity(sceneCoordinator: dependency.sceneCoordinator)]
        )
        return activityViewController
    }
}
