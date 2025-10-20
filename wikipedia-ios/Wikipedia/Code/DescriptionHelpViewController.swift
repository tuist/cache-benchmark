import WMFComponents

class DescriptionHelpViewController: ThemeableViewController, WMFNavigationBarConfiguring {

    @IBOutlet private weak var helpScrollView: UIScrollView!

    @IBOutlet private weak var aboutTitleLabel: UILabel!
    @IBOutlet private weak var aboutDescriptionLabel: UILabel!

    @IBOutlet private weak var tipsTitleLabel: UILabel!
    @IBOutlet private weak var tipsDescriptionLabel: UILabel!
    @IBOutlet private weak var tipsForExampleLabel: UILabel!

    @IBOutlet private weak var exampleOneTitleLabel: UILabel!
    @IBOutlet private weak var exampleOneDescriptionLabel: UILabel!

    @IBOutlet private weak var exampleTwoTitleLabel: UILabel!
    @IBOutlet private weak var exampleTwoDescriptionLabel: UILabel!

    @IBOutlet private weak var moreInfoTitleLabel: UILabel!
    @IBOutlet private weak var moreInfoDescriptionLabel: UILabel!

    @IBOutlet private weak var aboutWikidataLabel: UILabel!
    @IBOutlet private weak var wikidataGuideLabel: UILabel!

    @IBOutlet private var allLabels: [UILabel]!
    @IBOutlet private var headingLabels: [UILabel]!
    @IBOutlet private var italicLabels: [UILabel]!
    @IBOutlet private var exampleBackgroundViews: [UIView]!

    @IBOutlet private var imageViews: [UIImageView]!
    @IBOutlet private var dividerViews: [UIView]!
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        self.theme = Theme.standard
    }
    
    init(theme: Theme) {
        super.init(nibName: nil, bundle: nil)
        self.theme = theme
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutTitleLabel.text = WMFLocalizedString("description-help-about-title", value:"About", comment:"Description editing about label text")
        aboutDescriptionLabel.text = WMFLocalizedString("description-help-about-description", value:"Article descriptions summarize an article to help readers understand the subject at a glance.", comment:"Description editing details label text")
        
        tipsTitleLabel.text = WMFLocalizedString("description-help-tips-title", value:"Tips for creating descriptions", comment:"Description editing tips label text")
        tipsDescriptionLabel.text = WMFLocalizedString("description-help-tips-description", value:"Descriptions should ideally fit on one line, and are between two to twelve words long. They are not capitalized unless the first word is a proper noun.", comment:"Description editing tips details label text")
        tipsForExampleLabel.text = WMFLocalizedString("description-help-tips-for-example", value:"For example:", comment:"Examples label text")
        
        exampleOneTitleLabel.text = WMFLocalizedString("description-help-tips-example-title-one", value:"painting by Leonardo Da Vinci", comment:"First example label text")
        exampleOneDescriptionLabel.text = WMFLocalizedString("description-help-tips-example-description-one", value:"article description for an article about the Mona Lisa", comment:"First example description text")
        
        exampleTwoTitleLabel.text = WMFLocalizedString("description-help-tips-example-title-two", value:"Earth’s highest mountain", comment:"Second example label text")
        exampleTwoDescriptionLabel.text = WMFLocalizedString("description-help-tips-example-description-two", value:"article description for an article about Mount Everest", comment:"Second example description text")
        
        moreInfoTitleLabel.text = WMFLocalizedString("description-help-more-info-title", value:"More information", comment:"Article descriptions more info heading text")
        moreInfoDescriptionLabel.text = WMFLocalizedString("description-help-more-info-description", value:"Descriptions are stored and maintained on Wikidata, a project of the Wikimedia Foundation which provides a free, collaborative, multilingual, secondary database supporting Wikipedia and other projects.", comment:"Article descriptions more info details text")

        aboutWikidataLabel.text = WMFLocalizedString("description-help-about-wikidata", value:"About Wikidata", comment:"About Wikidata label text")
        wikidataGuideLabel.text = WMFLocalizedString("description-help-wikidata-guide", value:"Wikidata guide for writing descriptions", comment:"Wikidata guide label text")
        updateFonts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        
        let titleConfig = WMFNavigationBarTitleConfig(title: WMFLocalizedString("description-help-title", value:"Article description help", comment:"Title for description editing help page"), customView: nil, alignment: .centerCompact)
        
        let closeConfig = WMFNavigationBarCloseButtonConfig(text: CommonStrings.doneTitle, target: self, action: #selector(closeButtonPushed(_:)), alignment: .trailing)
        
        configureNavigationBar(titleConfig: titleConfig, closeButtonConfig: closeConfig, profileButtonConfig: nil, tabsButtonConfig: nil, searchBarConfig: nil, hideNavigationBarOnScroll: false)
    }
    
    @objc func closeButtonPushed(_ : UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    override func apply(theme: Theme) {
        self.theme = theme
        guard viewIfLoaded != nil else {
            return
        }
        view.backgroundColor = theme.colors.midBackground
        imageViews.forEach {
            $0.tintColor = theme.colors.primaryText
        }
        allLabels.forEach {
            $0.textColor = theme.colors.primaryText
        }
        exampleBackgroundViews.forEach {
            $0.backgroundColor = theme.colors.descriptionBackground
        }
        headingLabels.forEach {
            $0.textColor = theme.colors.secondaryText
        }
        dividerViews.forEach {
            $0.backgroundColor = theme.colors.border
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateFonts()
    }

    private func updateFonts() {
        allLabels.forEach {
            $0.set(dynamicTextStyle: .callout)
        }
        headingLabels.forEach {
            $0.set(dynamicTextStyle: .headline)
        }
        italicLabels.forEach {
            $0.set(dynamicTextStyle: .italicCallout)
        }
    }
    
    @IBAction func showAboutWikidataPage() {
        navigate(to: URL(string: "https://m.wikidata.org/wiki/Wikidata:Introduction"))
    }

    @IBAction func showWikidataGuidePage() {
        navigate(to: URL(string: "https://m.wikidata.org/wiki/Help:Description#Guidelines_for_descriptions_in_English"))
    }
}

private extension UILabel {
    func set(dynamicTextStyle: WMFFont) {
        font = WMFFont.for(dynamicTextStyle, compatibleWith: traitCollection)
    }
}
