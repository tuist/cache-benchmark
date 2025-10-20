//
//  ReportStatusTableViewCell+ViewModel.swift
//  Mastodon
//
//  Created by MainasuK on 2022-2-7.
//

import UIKit
import MastodonSDK
import MastodonUI

extension ReportStatusTableViewCell {
    // todo: refactor / remove this
    final class ViewModel {
        let value: MastodonStatus

        init(value: MastodonStatus) {
            self.value = value
        }
    }
}

extension ReportStatusTableViewCell {

    func configure(
        tableView: UITableView,
        viewModel: ViewModel
    ) {
        if statusView.frame == .zero {
            // set status view width
            statusView.frame.size.width = tableView.frame.width - ReportStatusTableViewCell.checkboxLeadingMargin - ReportStatusTableViewCell.checkboxSize.width - ReportStatusTableViewCell.statusViewLeadingSpacing
        }
        
        let contentDisplayMode = StatusView.ContentConcealViewModel(status: viewModel.value, filterBox: nil, filterContext: nil).byShowingAll().effectiveDisplayMode
        
        statusView.configure(status: viewModel.value, contentDisplayMode: contentDisplayMode)
    }
    
}
