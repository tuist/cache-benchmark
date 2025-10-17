//
//  HashtagTimelineViewModel+Diffable.swift
//  Mastodon
//
//  Created by BradGao on 2021/3/30.
//

import UIKit
import Combine
import CoreData
import CoreDataStack

extension HashtagTimelineViewModel {
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

        stateMachine.enter(State.Reloading.self)
        
        var snapshot = NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>()
        snapshot.appendSections([.main])
        diffableDataSource?.apply(snapshot)

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
                    case is State.Initial,
                        is State.Reloading,
                        is State.Loading,
                        is State.Idle,
                        is State.Fail:
                        if !items.isEmpty {
                            snapshot.appendItems([.bottomLoader], toSection: .main)
                        }
                    case is State.NoMore:
                        break
                    default:
                        assertionFailure()
                        break
                    }
                }
                
                diffableDataSource.apply(snapshot)
            }
            .store(in: &disposeBag)
    }
}
