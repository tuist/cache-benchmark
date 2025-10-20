//
//  RebloggedByViewController+DataSourceProvider.swift
//  Mastodon
//
//  Created by MainasuK on 2022-5-17.
//

import UIKit
import MastodonSDK

extension RebloggedByViewController: DataSourceProvider {
    var filterContext: MastodonSDK.Mastodon.Entity.FilterContext? {
        .none
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
            case .account(let account, let relationship):
                return .account(account: account, relationship: relationship)
            case .bottomHeader(_), .bottomLoader:
                return nil
        }
    }
    
    func update(contentStatus: MastodonStatus, intent: MastodonStatus.UpdateIntent) {
        assertionFailure("Not required")
    }
    
    @MainActor
    private func indexPath(for cell: UITableViewCell) async -> IndexPath? {
        return tableView.indexPath(for: cell)
    }
}
