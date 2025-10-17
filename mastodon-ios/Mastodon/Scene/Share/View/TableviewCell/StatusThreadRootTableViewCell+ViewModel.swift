//
//  StatusThreadRootTableViewCell+ViewModel.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-17.
//

import UIKit
import MastodonSDK

extension StatusThreadRootTableViewCell {

    func configure(
        tableView: UITableView,
        viewModel: StatusTableViewCell.StatusTableViewCellViewModel,
        delegate: StatusTableViewCellDelegate?
    ) {
        guard let status = viewModel.statusItem.status else { return }
        
        if statusView.frame == .zero {
            // set status view width
            statusView.frame.size.width = tableView.frame.width - containerViewHorizontalMargin
        }

        statusView.configure(status: status, contentDisplayMode: viewModel.contentConcealModel.effectiveDisplayMode)
        
        self.delegate = delegate
    }
    
}
