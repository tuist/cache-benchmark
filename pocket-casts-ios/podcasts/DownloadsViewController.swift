import DifferenceKit
import SwiftUI
import PocketCastsDataModel
import PocketCastsServer
import PocketCastsUtils
import UIKit

class DownloadsViewController: PCViewController {
    var episodes = [ArraySection<String, ListEpisode>]() {
        didSet {
            refreshContentUnavailable()
        }
    }
    var cellHeights: [IndexPath: CGFloat] = [:]

    private let episodesDataManager = EpisodesDataManager()

    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1

        return queue
    }()

    @IBOutlet var downloadsTable: UITableView! {
        didSet {
            registerTableCells()
            registerLongPress()
            downloadsTable.estimatedRowHeight = 80.0
            downloadsTable.rowHeight = UITableView.automaticDimension
            downloadsTable.allowsMultipleSelectionDuringEditing = true
        }
    }

    var isMultiSelectEnabled = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.setupNavBar()
                self.downloadsTable.beginUpdates()
                self.downloadsTable.setEditing(self.isMultiSelectEnabled, animated: true)
                self.insetAdjuster.isMultiSelectEnabled = isMultiSelectEnabled
                self.downloadsTable.endUpdates()

                if self.isMultiSelectEnabled {
                    Analytics.track(.downloadsMultiSelectEntered)
                    self.multiSelectFooter.setSelectedCount(count: self.selectedEpisodes.count)
                    self.multiSelectFooterBottomConstraint.constant = PlaybackManager.shared.currentEpisode() == nil ? 16 : Constants.Values.miniPlayerOffset + 16
                    if let selectedIndexPath = self.longPressMultiSelectIndexPath {
                        self.downloadsTable.selectIndexPath(selectedIndexPath)
                        self.longPressMultiSelectIndexPath = nil
                    }
                } else {
                    Analytics.track(.downloadsMultiSelectExited)
                    self.selectedEpisodes.removeAll()
                }
            }
        }
    }

    var multiSelectGestureInProgress = false
    var longPressMultiSelectIndexPath: IndexPath?
    @IBOutlet var multiSelectFooter: MultiSelectFooterView! {
        didSet {
            multiSelectFooter.delegate = self
        }
    }

    @IBOutlet var multiSelectFooterBottomConstraint: NSLayoutConstraint!

    var selectedEpisodes = [ListEpisode]() {
        didSet {
            multiSelectFooter.setSelectedCount(count: selectedEpisodes.count)
            updateSelectAllBtn()
        }
    }

    // MARK: - View Methods

    override func viewDidLoad() {
        setupNavBar()
        super.viewDidLoad()

        downloadsTable.tableFooterView = UIView(frame: CGRect.zero)
        downloadsTable.sectionFooterHeight = 0.0

        insetAdjuster.setupInsetAdjustmentsForMiniPlayer(scrollView: downloadsTable)

        title = L10n.downloads
        view.backgroundColor = ThemeColor.primaryUi02()

        showManageDownloadsBanner()

        Analytics.track(.downloadsShown)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.shadowImage = nil

        reloadEpisodes()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showManageDownloadsBanner()
        addEventObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        removeAllCustomObservers()
    }

    private func showManageDownloadsBanner() {
        guard ManageDownloadsCoordinator.shouldShowBanner
        else {
            downloadsTable.tableHeaderView = nil
            return
        }
        Analytics.track(.freeUpSpaceBannerShown)
        downloadsTable.tableHeaderView = bannerView
    }

    private lazy var bannerView: UIView = {
        let model = ManageDownloadsModel(initialSize: "",
                                         onManageTap: { [weak self] in
            Analytics.track(.freeUpSpaceManageDownloadsTapped, properties: ["source": "downloads"])
            self?.navigationController?.pushViewController(DownloadedFilesViewController(), animated: true)
        }, onNotNowTap: { [weak self] in
            Analytics.track(.freeUpSpaceMaybeLaterTapped, properties: ["source": "downloads"])
            Settings.manageDownloadsLastCheckDate = Date.now
            self?.showManageDownloadsBanner()
            self?.downloadsTable.reloadData()
        })
        let banner = ManageDownloadsBannerView(dataModel: model).themedUIView
        banner.translatesAutoresizingMaskIntoConstraints = false
        let wrapperView = UIView(frame: CGRect(x: 116, y: 0, width: 200, height: 132))
        wrapperView.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor, constant: 16),
            banner.trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor, constant: -16),
            banner.topAnchor.constraint(equalTo: wrapperView.topAnchor, constant: 16),
            banner.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor, constant: 0),
            ])
        return wrapperView
    }()

    // MARK: - App Backgrounding

    override func handleAppWillBecomeActive() {
        reloadEpisodes()
        addEventObservers()
    }

    override func handleAppDidEnterBackground() {
        // we don't need to keep our UI up to date while backgrounded, so remove all the notification observers we have
        removeAllCustomObservers()
    }

    @objc private func refreshView() {
        reloadEpisodes()
    }

    private func refreshContentUnavailable() {
        var config: UIContentConfiguration?

        if episodes.isEmpty {
            let title = L10n.downloadsNoDownloadsTitle
            let message = L10n.downloadsNoDownloadsDesc
            config = ContentUnavailableConfiguration.emptyState(title: title, message: message, icon: { Image("filter_downloaded") })
        }

        if #available(iOS 17.0, *) {
            self.contentUnavailableConfiguration = config
        } else {
            self.setContentUnavailableConfiguration(config)
        }
    }

    override func handleThemeChanged() {
        downloadsTable.reloadData()
        view.backgroundColor = ThemeColor.primaryUi02()
    }

    private func addEventObservers() {
        addCustomObserver(ServerNotifications.podcastsRefreshed, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.opmlImportCompleted, selector: #selector(refreshView))

        addCustomObserver(Constants.Notifications.episodeDownloaded, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.playbackTrackChanged, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.playbackEnded, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.upNextEpisodeRemoved, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.upNextEpisodeAdded, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.episodeStarredChanged, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.upNextQueueChanged, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.episodeArchiveStatusChanged, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.episodeDownloadStatusChanged, selector: #selector(refreshView))
        addCustomObserver(Constants.Notifications.manyEpisodesChanged, selector: #selector(refreshView))
    }

    func reloadEpisodes() {
        operationQueue.addOperation { [weak self] in
            guard let self else { return }

            let newData = self.episodesDataManager.downloadedEpisodes()

            DispatchQueue.main.sync {
                self.downloadsTable.isHidden = (newData.count == 0)
                self.episodes = newData
                self.downloadsTable.reloadData()
            }
        }
    }

    func setupNavBar() {
        supportsGoogleCast = isMultiSelectEnabled ? false : true
        super.customRightBtn = isMultiSelectEnabled ? UIBarButtonItem(title: L10n.cancel, style: .plain, target: self, action: #selector(cancelTapped)) : UIBarButtonItem(image: UIImage(named: "more"), style: .plain, target: self, action: #selector(menuTapped))
        super.customRightBtn?.accessibilityLabel = isMultiSelectEnabled ? L10n.accessibilityCancelMultiselect : L10n.accessibilitySortAndOptions

        navigationItem.leftBarButtonItem = isMultiSelectEnabled ? UIBarButtonItem(title: L10n.selectAll, style: .done, target: self, action: #selector(selectAllTapped)) : nil
        navigationItem.backBarButtonItem = isMultiSelectEnabled ? nil : UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @objc private func doneTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func menuTapped(_ sender: UIBarButtonItem) {
        Analytics.track(.downloadsOptionsButtonTapped)

        let optionsPicker = OptionsPicker(title: nil)

        let MultiSelectAction = OptionAction(label: L10n.selectEpisodes, icon: "option-multiselect") { [weak self] in
            Analytics.track(.downloadsOptionsModalOptionTapped, properties: ["option": "select_episodes"])
            self?.isMultiSelectEnabled = true
        }
        optionsPicker.addAction(action: MultiSelectAction)

        let settingsAction = OptionAction(label: L10n.downloadsAutoDownload, icon: "podcast-settings") { [weak self] in
            Analytics.track(.downloadsOptionsModalOptionTapped, properties: ["option": "auto_download_settings"])
            self?.navigationController?.pushViewController(DownloadSettingsViewController(), animated: true)
        }
        optionsPicker.addAction(action: settingsAction)

        if failedEpisodes().count > 0 {
            let retryAction = OptionAction(label: L10n.downloadsRetryFailedDownloads, icon: "option-download-retry") { [weak self] in
                Analytics.track(.downloadsOptionsModalOptionTapped, properties: ["option": "retry_failed_downloads"])
                self?.retryAllFailed(sender)
            }
            optionsPicker.addAction(action: retryAction)
        }

        if downloadingEpisodes().count > 0 {
            let stopAction = OptionAction(label: L10n.downloadsStopAllDownloads, icon: "option-cross-circle") { [weak self] in
                Analytics.track(.downloadsOptionsModalOptionTapped, properties: ["option": "stop_all_downloads"])
                self?.pauseAllDownloads()
            }
            optionsPicker.addAction(action: stopAction)
        }

        let cleanupAction = OptionAction(label: L10n.cleanUp, icon: "list_delete") { [weak self] in
            Analytics.track(.downloadsOptionsModalOptionTapped, properties: ["option": "clean_up"])
            self?.navigationController?.pushViewController(DownloadedFilesViewController(), animated: true)
        }
        optionsPicker.addAction(action: cleanupAction)

        optionsPicker.show(statusBarStyle: preferredStatusBarStyle)
    }

    private func pauseAllDownloads() {
        let episodeToPause = downloadingEpisodes()
        for episode in episodeToPause {
            DownloadManager.shared.removeFromQueue(episodeUuid: episode.uuid, fireNotification: false, userInitiated: false)
        }

        refreshView()
    }

    private func retryAllFailed(_ barButton: UIBarButtonItem) {
        retryAllFailed()
    }

    private func retryAllFailed() {
        NetworkUtils.shared.downloadEpisodeRequested(autoDownloadStatus: .notSpecified, { later in
            let failedList = self.failedEpisodes()
            for episode in failedList {
                if later {
                    DownloadManager.shared.queueForLaterDownload(episodeUuid: episode.uuid, fireNotification: false, autoDownloadStatus: .notSpecified)
                } else {
                    DownloadManager.shared.addToQueue(episodeUuid: episode.uuid, fireNotification: false, autoDownloadStatus: .notSpecified)
                }
            }

            self.refreshView()
        }, disallowed: nil)
    }

    private func failedEpisodes() -> [Episode] {
        var failedList = [Episode]()

        for section in episodes {
            for listEpisode in section.elements {
                if listEpisode.episode.downloadFailed() {
                    failedList.append(listEpisode.episode)
                }
            }
        }

        return failedList
    }

    private func downloadingEpisodes() -> [Episode] {
        var downloadingList = [Episode]()

        for section in episodes {
            for listEpisode in section.elements {
                if listEpisode.episode.downloading() || listEpisode.episode.queued() {
                    downloadingList.append(listEpisode.episode)
                }
            }
        }

        return downloadingList
    }
}

// MARK: - Analytics

extension DownloadsViewController: AnalyticsSourceProvider {
    var analyticsSource: AnalyticsSource {
        .downloads
    }
}
