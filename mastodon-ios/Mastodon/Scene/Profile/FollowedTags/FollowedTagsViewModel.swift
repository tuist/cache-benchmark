//
//  FollowedTagsViewModel.swift
//  Mastodon
//
//  Created by Marcus Kida on 23.11.22.
//

import UIKit
import MastodonSDK
import MastodonCore

final class FollowedTagsViewModel: NSObject {
    private(set) var followedTags: [Mastodon.Entity.Tag]

    private weak var tableView: UITableView?
    var diffableDataSource: UITableViewDiffableDataSource<Section, Item>?

    // input
    let authenticationBox: MastodonAuthenticationBox

    init(authenticationBox: MastodonAuthenticationBox) {
        self.authenticationBox = authenticationBox
        self.followedTags = []

        super.init()
    }
}

extension FollowedTagsViewModel {
    func setupTableView(_ tableView: UITableView) {
        setupDiffableDataSource(tableView: tableView)
        
        fetchFollowedTags()
    }
    
    func fetchFollowedTags(completion: (() -> Void)? = nil ) {
        Task { @MainActor in
            do {
                followedTags = try await APIService.shared.getFollowedTags(
                    domain: authenticationBox.domain,
                    query: Mastodon.API.Account.FollowedTagsQuery(limit: nil),
                    authenticationBox: authenticationBox
                ).value

                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                snapshot.appendSections([.main])
                let items = followedTags.compactMap { Item.hashtag($0) }
                snapshot.appendItems(items, toSection: .main)

                await diffableDataSource?.apply(snapshot)
            } catch {}

            completion?()
        }
    }

    func followOrUnfollow(_ tag: Mastodon.Entity.Tag) {
        Task { @MainActor in
            if tag.following ?? false {
                _ = try? await APIService.shared.unfollowTag(
                    for: tag.name,
                    authenticationBox: authenticationBox
                )
            } else {
                _ = try? await APIService.shared.followTag(
                    for: tag.name,
                    authenticationBox: authenticationBox
                )
            }
            
            fetchFollowedTags()
        }
    }
}

