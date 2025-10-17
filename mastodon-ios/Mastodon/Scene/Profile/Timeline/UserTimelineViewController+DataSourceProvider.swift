//
//  UserTimelineViewController+DataSourceProvider.swift
//  Mastodon
//
//  Created by MainasuK on 2022-1-18.
//

import UIKit
import MastodonSDK

extension UserTimelineViewController: DataSourceProvider {
    var filterContext: MastodonSDK.Mastodon.Entity.FilterContext? {
        return .none
    }
    
    func didToggleContentWarningDisplayStatus(status: MastodonSDK.MastodonStatus) {
        tableView.reloadData()
    }
    
    func item(from source: DataSourceItem.Source) async -> DataSourceItem? {
        var _indexPath = source.indexPath
        if _indexPath == nil, let cell = source.tableViewCell {
            _indexPath = await self.indexPath(for: cell)
        }
        guard let indexPath = _indexPath else { return nil }
        
        guard let item = viewModel.diffableDataSource?.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        switch item {
        case .status(let record):
            return .status(record: record)
        default:
            return nil
        }
    }
    
    func update(contentStatus: MastodonStatus, intent: MastodonStatus.UpdateIntent) {
        viewModel.dataController.update(status: contentStatus, intent: intent)
    }

    @MainActor
    private func indexPath(for cell: UITableViewCell) async -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
}
