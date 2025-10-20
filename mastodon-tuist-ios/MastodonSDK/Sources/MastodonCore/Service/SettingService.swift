//
//  SettingService.swift
//  Mastodon
//
//  Created by MainasuK Cirno on 2021-4-25.
//

import UIKit
import Combine
import CoreDataStack
import MastodonSDK
import MastodonAsset
import MastodonLocalization
import MastodonCommon

@MainActor
public final class SettingService {
    
    public static let shared = { SettingService() }()
    
    var disposeBag = Set<AnyCancellable>()
    
    // input
    var apiService: APIService { APIService.shared }
    var notificationService: NotificationService { NotificationService.shared
    }
    // output
    let settingFetchedResultController: SettingFetchedResultController
    public let currentSetting = CurrentValueSubject<Setting?, Never>(nil)
    
    private init() {
        self.settingFetchedResultController = SettingFetchedResultController()

        // create setting (if non-exist) for authenticated users
        AuthenticationServiceProvider.shared.$mastodonAuthenticationBoxes
            .compactMap { [weak self] mastodonAuthenticationBoxes -> AnyPublisher<[MastodonAuthenticationBox], Never>? in
                guard let self = self else { return nil }
                
                let managedObjectContext = PersistenceManager.shared.backgroundManagedObjectContext
                return managedObjectContext.performChanges {
                    for authenticationBox in mastodonAuthenticationBoxes {
                        let domain = authenticationBox.domain
                        let userID = authenticationBox.userID
                        _ = APIService.CoreData.createOrMergeSetting(
                            into: managedObjectContext,
                            property: Setting.Property(
                                domain: domain,
                                userID: userID
                            )
                        )
                    }   // end for
                }
                .map { _ in mastodonAuthenticationBoxes }
                .eraseToAnyPublisher()
            }
            .sink { _ in
                // do nothing
            }
            .store(in: &disposeBag)
        
        // bind current setting
        Publishers.CombineLatest(
            AuthenticationServiceProvider.shared.$mastodonAuthenticationBoxes,
            settingFetchedResultController.settings
        )
        .sink { [weak self] mastodonAuthenticationBoxes, settings in
            guard let self = self else { return }
            guard let activeMastodonAuthenticationBox = mastodonAuthenticationBoxes.first else { return }
            let currentSetting = setting(for: activeMastodonAuthenticationBox)
            self.currentSetting.value = currentSetting
        }
        .store(in: &disposeBag)
    }
}

extension SettingService {
    
    public static func openSettingsAlertController(title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let settingAction = UIAlertAction(title: L10n.Common.Controls.Actions.settings, style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        alertController.addAction(settingAction)
        let cancelAction = UIAlertAction(title: L10n.Common.Controls.Actions.cancel, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        return alertController
    }
}

extension SettingService {
    public func setting(for userAuthBox: MastodonAuthenticationBox) -> Setting? {
        return settingFetchedResultController.settings.value.first(where: { setting in
            return setting.domain == userAuthBox.domain
            && setting.userID == userAuthBox.userID
        })
    }
}
