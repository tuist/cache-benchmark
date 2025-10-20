//
//  HomeTimelineViewModel+Diffable.swift
//  Mastodon
//
//  Created by sxiaojian on 2021/2/7.
//

import UIKit
import MastodonUI
import MastodonSDK
import MastodonCore

extension HomeTimelineViewModel {
    
    func setupDiffableDataSource(
        tableView: UITableView,
        filterContext: Mastodon.Entity.FilterContext?,
        statusTableViewCellDelegate: StatusTableViewCellDelegate,
        timelineMiddleLoaderTableViewCellDelegate: TimelineMiddleLoaderTableViewCellDelegate
    ) {
        diffableDataSource = StatusSection.diffableDataSource(
            tableView: tableView,
            configuration: StatusSection.Configuration(
                authenticationBox: authenticationBox,
                statusTableViewCellDelegate: statusTableViewCellDelegate,
                timelineMiddleLoaderTableViewCellDelegate: timelineMiddleLoaderTableViewCellDelegate,
                filterContext: filterContext  // should be .home
            )
        )

        // make initial snapshot animation smooth
        var snapshot = NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>()
        snapshot.appendSections([.main])
        diffableDataSource?.apply(snapshot)
        
        dataController.$records
            .receive(on: DispatchQueue.main)
            .sink { [weak self] records in
                guard let self = self else { return }
                guard let diffableDataSource = self.diffableDataSource else { return }

                guard let currentState = loadLatestStateMachine.currentState as? HomeTimelineViewModel.LoadLatestState,
                      (currentState.self is HomeTimelineViewModel.LoadLatestState.ContextSwitch) == false else { return }

                Task { @MainActor in
                    let oldSnapshot = diffableDataSource.snapshot()
                    var newSnapshot: NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier> = {
                        let newItems = records.map { record in
                            MastodonItemIdentifier.feed(record)
                        }.removingDuplicates()
                        var snapshot = NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>()
                        snapshot.appendSections([.main])
                        snapshot.appendItems(newItems, toSection: .main)
                        return snapshot
                    }()

                    let anchors: [MastodonFeed] = records.filter { $0.hasMore == true }
                    let itemIdentifiers = newSnapshot.itemIdentifiers
                    for (index, item) in itemIdentifiers.enumerated() {
                        guard case let .feed(record) = item else { continue }
                        guard anchors.contains(where: { feed in feed.id == record.id }) else { continue }
                        let isLast = index + 1 == itemIdentifiers.count
                        if isLast {
                            newSnapshot.insertItems([.bottomLoader], afterItem: item)
                        } else {
                            newSnapshot.insertItems([.feedLoader(feed: record)], afterItem: item)
                        }
                    }

                    let hasChanges = newSnapshot.itemIdentifiers != oldSnapshot.itemIdentifiers
                    if !hasChanges && !self.hasPendingStatusEditReload {
                        self.didLoadLatest.send()
                        return
                    }

                    await self.updateTableView(tableView, toNewSnapshot: newSnapshot, withoutLosingScrollFrom: oldSnapshot)
                }   // end Task
            }
            .store(in: &disposeBag)
    }
    
    private func updateTableView(_ tableView: UITableView, toNewSnapshot newSnapshot: NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>, withoutLosingScrollFrom oldSnapshot: NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>) async {
        let lastRead = await BodegaPersistence.LastRead.lastReadMarkers(for: authenticationBox)?.homeTimelineLastRead?.lastReadID
        guard let difference = self.calculateReloadSnapshotDifference(
            tableView: tableView,
            oldSnapshot: oldSnapshot,
            newSnapshot: newSnapshot,
            lastRead: lastRead
        ) else {
            await self.updateDataSource(snapshot: newSnapshot, animatingDifferences: false)
            self.didLoadLatest.send()
            return
        }
        
        await self.updateDataSource(snapshot: newSnapshot, animatingDifferences: false)
        let tableViewContainsTargetIndexPath = difference.targetIndexPath.section < tableView.numberOfSections  && difference.targetIndexPath.row < tableView.numberOfRows(inSection: difference.targetIndexPath.section)
        if tableViewContainsTargetIndexPath {
            tableView.scrollToRow(at: difference.targetIndexPath, at: .top, animated: false)
            var contentOffset = tableView.contentOffset
            contentOffset.y = tableView.contentOffset.y - difference.sourceDistanceToTableViewTopEdge
            tableView.setContentOffset(contentOffset, animated: false)
        }
        self.didLoadLatest.send()
        self.hasPendingStatusEditReload = false
        
    }
    
}


extension HomeTimelineViewModel {
    
    @MainActor func updateDataSource(
        snapshot: NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>,
        animatingDifferences: Bool
    ) async {
        await diffableDataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    @MainActor func updateSnapshotUsingReloadData(
        snapshot: NSDiffableDataSourceSnapshot<StatusSection, MastodonItemIdentifier>
    ) {
        self.diffableDataSource?.applySnapshotUsingReloadData(snapshot)
    }
    
    struct Difference<T> {
        let item: T
        let sourceDistanceToTableViewTopEdge: CGFloat
        let targetIndexPath: IndexPath
    }

    @MainActor private func calculateReloadSnapshotDifference<S: Hashable, T: Hashable>(
        tableView: UITableView,
        oldSnapshot: NSDiffableDataSourceSnapshot<S, T>,
        newSnapshot: NSDiffableDataSourceSnapshot<S, T>,
        lastRead: Mastodon.Entity.Status.ID?
    ) -> Difference<T>? {
        var anchorItem: T? = nil
        let targetIndexPath: IndexPath?
        let currentDistanceFromFirstVisibleCellToTableViewTopEdge: CGFloat
        
        if let firstVisibleIndexPath = (tableView.indexPathsForVisibleRows ?? []).sorted().first {
            let rectForCurrentFirstVisibleCell = tableView.rectForRow(at: firstVisibleIndexPath)
            currentDistanceFromFirstVisibleCellToTableViewTopEdge = {
                if tableView.window != nil {
                    return tableView.convert(rectForCurrentFirstVisibleCell, to: nil).origin.y - tableView.safeAreaInsets.top
                } else {
                    return rectForCurrentFirstVisibleCell.origin.y - tableView.contentOffset.y - tableView.safeAreaInsets.top
                }
            }()
            
            guard firstVisibleIndexPath.section < oldSnapshot.numberOfSections,
                  firstVisibleIndexPath.row < oldSnapshot.numberOfItems(inSection: oldSnapshot.sectionIdentifiers[firstVisibleIndexPath.section])
            else { assertionFailure("tableview not in sync with oldSnapshot"); return nil }
            
            let anchorSectionIdentifier = oldSnapshot.sectionIdentifiers[firstVisibleIndexPath.section]
            anchorItem = oldSnapshot.itemIdentifiers(inSection: anchorSectionIdentifier)[firstVisibleIndexPath.row]
            
            guard let anchorItem, let targetIndexPathRow = newSnapshot.indexOfItem(anchorItem),
                  let newSectionIdentifier = newSnapshot.sectionIdentifier(containingItem: anchorItem),
                  let targetIndexPathSection = newSnapshot.indexOfSection(newSectionIdentifier)
            else { return nil }
            
            targetIndexPath = IndexPath(row: targetIndexPathRow, section: targetIndexPathSection)
        } else {
            let lastReadIndexPath: IndexPath? = {
                guard let lastRead else { return nil }
                for (index, item) in newSnapshot.itemIdentifiers.enumerated() {
                    switch (item as? MastodonItemIdentifier) {
                    case .status(let status):
                        if status.id == lastRead {
                            anchorItem = item
                            return IndexPath(row: index, section: 0)
                        }
                    case .feed(let feed):
                        if lastRead == feed.id {
                            anchorItem = item
                            return IndexPath(row: index, section: 0)
                        }
                    default:
                        break
                    }
                }
                return nil
            }()
            targetIndexPath = lastReadIndexPath
            currentDistanceFromFirstVisibleCellToTableViewTopEdge = 0
        }
            
        guard let anchorItem, let targetIndexPath else { return nil }
        
        
        return Difference(
            item: anchorItem,
            sourceDistanceToTableViewTopEdge: currentDistanceFromFirstVisibleCellToTableViewTopEdge,
            targetIndexPath: targetIndexPath
        )
    }
    
}
