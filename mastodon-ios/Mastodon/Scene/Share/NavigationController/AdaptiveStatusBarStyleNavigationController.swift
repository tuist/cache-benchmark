//
//  AdaptiveStatusBarStyleNavigationController.swift
//  
//
//  Created by MainasuK Cirno on 2021-2-26.
//

import UIKit

class AdaptiveStatusBarStyleNavigationController: UINavigationController {

    private lazy var fullWidthBackGestureRecognizer = UIPanGestureRecognizer()
    
    private let centeredWidthLimitedContainerView = UIView() // to keep the displayed controller at a reasonable reading width (eg, when on iPad in landscape)

    // Make status bar style adaptive for child view controller
    // SeeAlso: `modalPresentationCapturesStatusBarAppearance`
    override var childForStatusBarStyle: UIViewController? {
        topViewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutTopViewControllerInCenteredContainer()
    }
}

// ref: https://stackoverflow.com/a/60598558/3797903
extension AdaptiveStatusBarStyleNavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCenteredContainerView()
        setupFullWidthBackGesture()
    }

    private func setupFullWidthBackGesture() {
        // The trick here is to wire up our full-width `fullWidthBackGestureRecognizer` to execute the same handler as
        // the system `interactivePopGestureRecognizer`. That's done by assigning the same "targets" (effectively
        // object and selector) of the system one to our gesture recognizer.
        guard let interactivePopGestureRecognizer = interactivePopGestureRecognizer,
              let targets = interactivePopGestureRecognizer.value(forKey: "targets")
        else { return }

        fullWidthBackGestureRecognizer.setValue(targets, forKey: "targets")
        fullWidthBackGestureRecognizer.delegate = self
        view.addGestureRecognizer(fullWidthBackGestureRecognizer)
    }
    
    private func setupCenteredContainerView() {
        centeredWidthLimitedContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(centeredWidthLimitedContainerView, belowSubview: navigationBar)
        
        NSLayoutConstraint.activate([
            centeredWidthLimitedContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centeredWidthLimitedContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            centeredWidthLimitedContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            centeredWidthLimitedContainerView.widthAnchor.constraint(equalToConstant: 700).priority(.defaultHigh), // Limit width
            centeredWidthLimitedContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor), // Prevent overflow
            centeredWidthLimitedContainerView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor)   // Prevent overflow
        ])
    }
    
    private func layoutTopViewControllerInCenteredContainer() {
        guard let topVC = topViewController else { return }
        
        if topVC.view.superview != centeredWidthLimitedContainerView {
            // Remove from old superview and add to container
            topVC.view.removeFromSuperview()
            centeredWidthLimitedContainerView.addSubview(topVC.view)
            
            topVC.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                topVC.view.leadingAnchor.constraint(equalTo: centeredWidthLimitedContainerView.leadingAnchor),
                topVC.view.trailingAnchor.constraint(equalTo: centeredWidthLimitedContainerView.trailingAnchor),
                topVC.view.topAnchor.constraint(equalTo: centeredWidthLimitedContainerView.topAnchor),
                topVC.view.bottomAnchor.constraint(equalTo: centeredWidthLimitedContainerView.bottomAnchor)
            ])
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension AdaptiveStatusBarStyleNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isSystemSwipeToBackEnabled = interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = viewControllers.count > 1
        let isPanPopable = (topViewController as? PanPopableViewController)?.isPanPopable ?? true
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers && isPanPopable
    }
}

protocol PanPopableViewController: UIViewController {
    var isPanPopable: Bool { get }
}
