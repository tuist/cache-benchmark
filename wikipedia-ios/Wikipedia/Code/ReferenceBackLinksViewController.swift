import WMFComponents

class ReferenceBackLinksViewController: ReferenceViewController {
    var index = 0
    let backLinks: [ReferenceBackLink]
    
    lazy var toolbarContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var toolbar: UIToolbar = {
        let tb = UIToolbar()
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    init?(referenceId: String, referenceText:String, backLinks: [ReferenceBackLink], delegate: ReferenceBackLinksViewControllerDelegate?, theme: Theme) {
        guard backLinks.count > 0 else {
            return nil
        }
        self.backLinks = backLinks
        super.init(nibName: nil, bundle: nil)
        self.theme = theme
        self.referenceId = referenceId
        self.referenceLinkText = referenceText
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    lazy var nextButton = UIBarButtonItem(image:UIImage(named: "directionDown"), style: .plain, target: self, action: #selector(goToNextReference))
    lazy var previousButton = UIBarButtonItem(image:UIImage(named: "directionUp"), style: .plain, target: self, action: #selector(goToPreviousReference))
    lazy var countLabel = UILabel()
    lazy var countContainer: UIView = {
        let view = UIView()
        view.wmf_addSubviewWithConstraintsToEdges(countLabel)
        return view
    }()
    lazy var countItem = UIBarButtonItem(customView: countContainer)

    func setupToolbar() {
        
        toolbarContainerView.addSubview(toolbar)
        view.addSubview(toolbarContainerView)
        
        NSLayoutConstraint.activate([
            toolbarContainerView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toolbar.bottomAnchor),
            toolbarContainerView.leadingAnchor.constraint(equalTo: toolbar.leadingAnchor),
            toolbarContainerView.trailingAnchor.constraint(equalTo: toolbar.trailingAnchor),
            toolbarContainerView.topAnchor.constraint(equalTo: toolbar.topAnchor),
            view.bottomAnchor.constraint(equalTo: toolbarContainerView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: toolbarContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: toolbarContainerView.trailingAnchor)
        ])
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [countItem, flexibleSpace, previousButton, nextButton]

        if backLinks.count <= 1 {
            previousButton.isEnabled = false
            nextButton.isEnabled = false
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        countLabel.font = WMFFont.for(.footnote, compatibleWith: traitCollection)
    }
    
    // MARK: View Lifecycle
    
    override func loadView() {
        super.loadView()
        self.view = PassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        notifyDelegateOfNavigationToReference()

        countLabel.isAccessibilityElement = true
        nextButton.isAccessibilityElement = true
        previousButton.isAccessibilityElement = true
        accessibilityElements = [backToReferenceButton as Any, navigationItem.title as Any, closeButton as Any, countLabel as Any, previousButton as Any, nextButton as Any]
    }
    
    // MARK: Actions

    func notifyDelegateOfNavigationToReference() {

        let refNumber = index + 1
        let totalRef = backLinks.count
        countLabel.text = "\(refNumber)/\(totalRef)"
        let backLink = backLinks[index]
        (delegate as? ReferenceBackLinksViewControllerDelegate)?.referenceBackLinksViewControllerUserDidNavigateTo(referenceBackLink: backLink, referenceBackLinksViewController: self)
    }
    
    @objc func goToNextReference() {
        if index >= backLinks.count - 1 {
            index = 0
        } else {
            index += 1
        }
        notifyDelegateOfNavigationToReference()
    }

    
    @objc func goToPreviousReference() {
        if index <= 0 {
            index = backLinks.count - 1
        } else {
            index -= 1
        }
        notifyDelegateOfNavigationToReference()
    }

    // MARK: Theme
    
    override func apply(theme: Theme) {
        super.apply(theme: theme)
        guard viewIfLoaded != nil else {
            return
        }
        countLabel.textColor = theme.colors.secondaryText
        view.backgroundColor = .clear
        
        toolbarContainerView.backgroundColor = theme.colors.paperBackground
        toolbar.setBackgroundImage(theme.navigationBarBackgroundImage, forToolbarPosition: .any, barMetrics: .default)
        toolbar.isTranslucent = false
    }
}
