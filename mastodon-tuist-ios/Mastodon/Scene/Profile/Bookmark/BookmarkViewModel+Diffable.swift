//
//  BookmarkViewModel+Diffable.swift
//  Mastodon
//
//  Created by ProtoLimit on 2022-07-19.
//

import UIKit

extension BookmarkViewModel {
    
    func setupDiffableDataSource(
        tableView: UITableView,
        statusTableViewCellDelegate: StatusTableViewCellDelegate
    ) {
        diffableDataSource = StatusSection.diffableDataSource(
            tableView: tableView,
            configuration: StatusSection.Configuration(
                authenticationBox: authenticationBox,
                statusTableViewCellDelegate: statusTableViewCellDelegate,
                timelineMiddleLoaderTableViewCellDelegate: nil,
                filterContext: nil
            )
        )
        // set empty section to make update animation top-to-bottom style
        var snapshot = NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>()
        snapshot.appendSections([.main])
        diffableDataSource?.apply(snapshot)
        
        stateMachine.enter(State.Reloading.self)
        
        dataController.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self = self else { return }
                guard let diffableDataSource = self.diffableDataSource else { return }
                
                var snapshot = NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>()
                snapshot.appendSections([.main])
                
                let items = records.map { MastodonItemIdentifier.status($0) }
                snapshot.appendItems(items, toSection: .main)
                
                if let currentState = self.stateMachine.currentState {
                    switch currentState {
                    case is State.Reloading,
                        is State.Loading,
                        is State.Idle,
                        is State.Fail:
                        snapshot.appendItems([.bottomLoader], toSection: .main)
                    case is State.NoMore:
                        break
                    default:
                        assertionFailure()
                        break
                    }
                }
                
                diffableDataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &disposeBag)
    }
    
}
