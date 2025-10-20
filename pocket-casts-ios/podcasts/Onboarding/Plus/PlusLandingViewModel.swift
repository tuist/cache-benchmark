import Foundation
import PocketCastsServer
import PocketCastsUtils
import SwiftUI

class PlusLandingViewModel: PlusPurchaseModel {
    weak var navigationController: UINavigationController? = nil

    let displayedProducts: [UpgradeTier]
    var initialProduct: ProductInfo? = nil
    var continuePurchasing: ProductInfo? = nil
    let source: Source
    let viewSource: PlusUpgradeViewSource

    init(source: Source, viewSource: PlusUpgradeViewSource = .unknown, config: Config? = nil, purchaseHandler: IAPHelper = .shared) {
        let plus = UpgradeTier.plus.update(header: viewSource.paywallHeadline())
        self.displayedProducts = config?.products ?? [plus, .patron]
        self.initialProduct = config?.displayProduct
        self.continuePurchasing = config?.continuePurchasing
        self.source = source
        self.viewSource = viewSource

        super.init(purchaseHandler: purchaseHandler)

        self.loadPrices()
    }

    func unlockTapped(_ product: ProductInfo) {
        OnboardingFlow.shared.track(.plusPromotionUpgradeButtonTapped)

        guard SyncManager.isUserLoggedIn() else {
            presentLogin(with: product)
            return
        }

        loadPricesAndContinue(product: product)
    }

    override func didAppear() {
        OnboardingFlow.shared.track(.plusPromotionShown)

        guard let continuePurchasing else { return }

        // Don't continually show when the user dismisses
        self.continuePurchasing = nil

        loadPricesAndContinue(product: continuePurchasing)
    }

    override func didDismiss(type: OnboardingDismissType) {
        guard type == .swipe else { return }

        OnboardingFlow.shared.track(.plusPromotionDismissed)
    }

    func presentLogin(with product: ProductInfo? = nil) {
        let controller = LoginCoordinator.make(in: navigationController, continuePurchasing: product)
        navigationController?.pushViewController(controller, animated: true)
    }

    func dismissTapped(buttonTapped: Bool = false) {
        if buttonTapped {
            OnboardingFlow.shared.track(.plusPromotionNotNowButtonTapped)
        }
        OnboardingFlow.shared.track(.plusPromotionDismissed)

        guard source == .accountCreated && !FeatureFlag.newOnboardingAccountCreation.enabled else {
            navigationController?.dismiss(animated: true)
            return
        }

        let controller = WelcomeViewModel.make(in: navigationController, displayType: .newAccount)
        navigationController?.pushViewController(controller, animated: true)
    }

    func changedSubscriptionTier(_ index: Int) {
        let tier = displayedProducts[index]
        OnboardingFlow.shared.track(.plusPromotionSubscriptionTierChanged, properties: ["value": tier.title.lowercased()])
    }

    func changedSubscriptionPeriod(_ value: PlanFrequency) {
        OnboardingFlow.shared.track(.plusPromotionSubscriptionFrequencyChanged, properties: ["value": value.rawValue])
    }

    func termsOfUseTapped() {
        OnboardingFlow.shared.track(.plusPromotionTermsAndConditionsTapped)
    }

    func privacyPolicyTapped() {
        OnboardingFlow.shared.track(.plusPromotionPrivacyPolicyTapped)
    }

    func showError() {
        SJUIUtils.showAlert(title: L10n.plusUpgradeNoInternetTitle, message: L10n.plusUpgradeNoInternetMessage, from: navigationController)
    }

    private func loadPricesAndContinue(product: ProductInfo) {
        loadPrices {
            switch self.priceAvailability {
            case .available:
                self.showModal(product: product)
            case .failed:
                self.showError()
            default:
                break
            }
        }
    }

    enum Source {
        case upsell
        case login
        case accountCreated
        case accountScreen
    }

    struct Config {
        var products: [UpgradeTier]? = nil
        var displayProduct: ProductInfo? = nil
        var continuePurchasing: ProductInfo? = nil
    }
}

private extension PlusLandingViewModel {
    func showModal(product: ProductInfo) {
        guard let product = self.product(for: product.plan, frequency: product.frequency) else {
            state = .failed
            return
        }

        purchase(product: product.identifier)
        return
    }
}

extension PlusLandingViewModel {
    static func make(in navigationController: UINavigationController? = nil, from source: Source, viewSource: PlusUpgradeViewSource, config: PlusLandingViewModel.Config? = nil, customTitle: String? = nil) -> UIViewController {
        let viewModel = PlusLandingViewModel(source: source, viewSource: viewSource, config: config)

        let view = Self.view(with: viewModel, viewSource: viewSource)
        let controller = PlusHostingViewController(rootView: view)

        controller.viewModel = viewModel
        controller.navBarIsHidden = true

        // Create our own nav controller if we're not already going in one
        let navController = navigationController ?? UINavigationController(rootViewController: controller)
        viewModel.navigationController = navController
        viewModel.parentController = navController
        viewModel.customTitle = customTitle

        return (navigationController == nil) ? navController : controller
    }

    @ViewBuilder
    private static func view(with viewModel: PlusLandingViewModel, viewSource: PlusUpgradeViewSource) -> some View {
        if FeatureFlag.upgradeExperiment.enabled, !SubscriptionHelper.hasActiveSubscription(), viewSource.isEligibleForExperiment() {
            let variant = ABTestProvider.shared.variation(for: .pocketcastsPaywallUpgradeIOSABTest)
            let customTreatment = variant.getCustomTreatment()

            switch customTreatment {
            case .featuresTreatment:
                PlusPaywallContainer(viewModel: viewModel, type: .features)
            case .reviewsTreatment:
                PlusPaywallContainer(viewModel: viewModel, type: .reviews)
            default:
                defaultPaywall(with: viewModel)
            }
        } else {
            defaultPaywall(with: viewModel, headline: viewSource.paywallHeadline())
        }
    }

    @ViewBuilder
    private static func defaultPaywall(with viewModel: PlusLandingViewModel, headline: String? = nil) -> some View {
            UpgradeLandingView(viewModel: viewModel)
                .setupDefaultEnvironment(theme: Theme.init(previewTheme: .light))
    }
}
