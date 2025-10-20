import SwiftUI
import Combine

/// SwiftUI `View` via `UIHostingController` based Component
open class WMFComponentHostingController<HostedView: View>: UIHostingController<HostedView> {

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Public Properties

    var appEnvironment: WMFAppEnvironment {
        return WMFAppEnvironment.current
    }

    var theme: WMFTheme {
        return WMFAppEnvironment.current.theme
    }

    // MARK: - Public

    public override init(rootView: HostedView) {
        super.init(rootView: rootView)
        subscribeToAppEnvironmentChanges()
        setup()
    }

    public override init?(coder aDecoder: NSCoder, rootView: HostedView) {
        super.init(coder: aDecoder, rootView: rootView)
        subscribeToAppEnvironmentChanges()
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        subscribeToAppEnvironmentChanges()
        setup()
    }

    // MARK: - Lifecycle

    private func setup() {
        
    }

    // MARK: - WMFAppEnvironment Subscription

    private func subscribeToAppEnvironmentChanges() {
        WMFAppEnvironment.publisher
            .sink(receiveValue: { [weak self] _ in self?.appEnvironmentDidChange() })
            .store(in: &cancellables)
    }

    // MARK: - Subclass Overrides

    public func appEnvironmentDidChange() {
        overrideUserInterfaceStyle = appEnvironment.theme.userInterfaceStyle
        setNeedsStatusBarAppearanceUpdate()
    }

}
