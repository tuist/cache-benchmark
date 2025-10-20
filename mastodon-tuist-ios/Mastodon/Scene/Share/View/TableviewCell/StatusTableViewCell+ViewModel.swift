//
//  StatusTableViewCell+ViewModel.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-12.
//

import UIKit
import MastodonSDK
import MastodonUI

extension StatusTableViewCell {
    final class StatusTableViewCellViewModel {
        let statusItem: DisplayItem
        let contentConcealModel: StatusView.ContentConcealViewModel

        init(displayItem: DisplayItem, contentConcealModel: StatusView.ContentConcealViewModel) {
            self.statusItem = displayItem
            self.contentConcealModel = contentConcealModel
        }
        
        enum DisplayItem {
            case feed(MastodonFeed)
            case status(MastodonStatus)
            
            public var status: MastodonStatus? {
                switch self {
                case .feed(let feed):
                    return feed.status
                case .status(let status):
                    return status
                }
            }
        }
    }
}

extension StatusTableViewCell {

    func configure(
        tableView: UITableView,
        viewModel: StatusTableViewCellViewModel,
        delegate: StatusTableViewCellDelegate?
    ) {
        if statusView.frame == .zero {
            // set status view width
            statusView.frame.size.width = tableView.frame.width - containerViewHorizontalMargin
        }
        
        switch viewModel.statusItem {
        case .feed(let feed):
            statusView.configure(feed: feed, contentMode: viewModel.contentConcealModel.effectiveDisplayMode)
            self.separatorLine.isHidden = feed.hasMore
            feed.$hasMore.sink(receiveValue: { [weak self] hasMore in
                self?.separatorLine.isHidden = hasMore
            })
            .store(in: &disposeBag)
            
        case .status(let status):
            statusView.configure(status: status, contentDisplayMode: viewModel.contentConcealModel.effectiveDisplayMode)
        }
        
        self.delegate = delegate

        statusView.viewModel.$card
            .removeDuplicates()
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak tableView, weak self] _ in
                guard let tableView = tableView else { return }
                guard let _ = self else { return }

                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
            .store(in: &disposeBag)
    }
    
}
