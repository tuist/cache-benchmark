//
//  MastodonRegisterViewController.swift
//  Mastodon
//
//  Created by MainasuK Cirno on 2021-2-5.
//

import AlamofireImage
import Combine
import MastodonSDK
import PhotosUI
import UIKit
import SwiftUI
import MastodonUI
import MastodonAsset
import MastodonCore
import MastodonLocalization

final class MastodonRegisterViewController: UIViewController, OnboardingViewControllerAppearance {
    
    static let avatarImageMaxSizeInPixel = CGSize(width: 400, height: 400)
    
    var disposeBag = Set<AnyCancellable>()
    private var observations = Set<NSKeyValueObservation>()
    
    var viewModel: MastodonRegisterViewModel!
    private(set) lazy var mastodonRegisterView = MastodonRegisterView(viewModel: viewModel)

    var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.color = Asset.Colors.Brand.blurple.color
        return activityIndicator
    }()

    func nextBarButtonItem() -> UIBarButtonItem {
        return UIBarButtonItem(title: L10n.Common.Controls.Actions.next, style: .done, target: self, action: #selector(MastodonRegisterViewController.nextButtonPressed(_:)))
    }
}

extension MastodonRegisterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupOnboardingAppearance()
        viewModel.backgroundColor = view.backgroundColor ?? .clear
        defer {
            setupNavigationBarBackgroundView()
        }
        
        let hostingViewController = UIHostingController(rootView: mastodonRegisterView)
        hostingViewController.view.preservesSuperviewLayoutMargins = true
        addChild(hostingViewController)
        hostingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingViewController.view)
        hostingViewController.view.pinToParent()
        hostingViewController.view.backgroundColor = view.backgroundColor

      navigationItem.rightBarButtonItem = nextBarButtonItem()

        viewModel.$isAllValid
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAllValid in
                guard let self = self else { return }
                self.navigationItem.rightBarButtonItem?.isEnabled = isAllValid
            }
            .store(in: &disposeBag)

        viewModel.endEditing
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.view.endEditing(true)
            }
            .store(in: &disposeBag)

//        // return
//        if viewModel.approvalRequired {
//            reasonTextField.returnKeyType = .done
//        } else {
//            passwordTextField.returnKeyType = .done
//        }
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                guard let error = error as? Mastodon.API.Error else { return }
                let alertController = UIAlertController(for: error, title: L10n.Common.Alerts.SignUpFailure.title, preferredStyle: .alert)
                let okAction = UIAlertAction(title: L10n.Common.Controls.Actions.ok, style: .default, handler: nil)
                alertController.addAction(okAction)
                _ = self.sceneCoordinator?.present(
                    scene: .alertController(alertController: alertController),
                    from: nil,
                    transition: .alertController(animated: true, completion: nil)
                )
            }
            .store(in: &disposeBag)

        viewModel.$isRegistering
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isRegistering in
                guard let self = self else { return }

                let rightBarButtonItem: UIBarButtonItem
                if isRegistering {
                    self.activityIndicator.startAnimating()

                    rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
                    rightBarButtonItem.isEnabled = false
                } else {
                    self.activityIndicator.stopAnimating()

                    rightBarButtonItem = self.nextBarButtonItem()
                }
                self.navigationItem.rightBarButtonItem = rightBarButtonItem
            }
            .store(in: &disposeBag)

          title = L10n.Scene.Register.title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidAppear.send()
    }
    
    //MARK: - Actions
    @objc private func nextButtonPressed(_ sender: UIButton) {
        Task {
            await doRegisterUser()
        }
    }
    
    private func doRegisterUser() async {
        guard viewModel.isAllValid else { return }
        
        guard !viewModel.isRegistering else { return }
        viewModel.isRegistering = true
        
        await viewModel.submitValidatedUserRegistration(viewModel, true)
        
        viewModel.isRegistering = false
    }
}
