//
//  ThreadViewModel.swift
//  Mastodon
//
//  Created by MainasuK Cirno on 2021-4-12.
//

import UIKit
import Combine
import CoreData
import CoreDataStack
import GameplayKit
import MastodonSDK
import MastodonMeta
import MastodonAsset
import MastodonCore
import MastodonLocalization

@MainActor
class ThreadViewModel {
    
    var disposeBag = Set<AnyCancellable>()
    var rootItemObserver: AnyCancellable?
    
    // input
    let authenticationBox: MastodonAuthenticationBox
    let mastodonStatusThreadViewModel: MastodonStatusThreadViewModel
    
    // output
    var diffableDataSource: UITableViewDiffableDataSource<StatusSection, MastodonItemIdentifier>?
    @Published var root: MastodonItemIdentifier.Thread?
    @Published var threadContext: ThreadContext?
    @Published var hasPendingStatusEditReload = false
    
    let onDismiss = PassthroughSubject<MastodonStatus, Never>()
    let onEdit = PassthroughSubject<MastodonStatus, Never>()
    
    private(set) lazy var loadThreadStateMachine: GKStateMachine = {
        let stateMachine = GKStateMachine(states: [
            LoadThreadState.Initial(viewModel: self),
            LoadThreadState.Loading(viewModel: self),
            LoadThreadState.Fail(viewModel: self),
            LoadThreadState.NoMore(viewModel: self),
            
        ])
        stateMachine.enter(LoadThreadState.Initial.self)
        return stateMachine
    }()
    @Published var navigationBarTitle: MastodonMetaContent?
    
    init(
        authenticationBox: MastodonAuthenticationBox,
        optionalRoot: MastodonItemIdentifier.Thread?
    ) {
        self.authenticationBox = authenticationBox
        self.root = optionalRoot
        self.mastodonStatusThreadViewModel = MastodonStatusThreadViewModel(filterContext: .thread)
        // end init

        $root
            .receive(on: DispatchQueue.main)
            .sink { [weak self] root in
                guard let self = self else { return }
                guard case let .root(threadContext) = root else { return }
                let status = threadContext.status
                
                // bind threadContext
                self.threadContext = .init(
                    statusID: status.id,
                    replyToID: status.entity.inReplyToID
                )
                
                // bind titleView
                self.navigationBarTitle = {
                    let title = L10n.Scene.Thread.title(status.entity.account.displayNameWithFallback)
                    let content = MastodonContent(content: title, emojis: status.entity.account.emojis.asDictionary)
                    return try? MastodonMetaContent.convert(document: content)
                }()
            }
            .store(in: &disposeBag)
        
        PublisherService.shared
            .statusPublishResult
            .sink { [weak self] value in
                guard let self else { return }
                if case let Result.success(result) = value {
                    switch result {
                    case let .edit(content):
                        let status = content.value
                        let mastodonStatus = MastodonStatus.fromEntity(status)
                        self.hasPendingStatusEditReload = true
                        if status.id == root?.record.id {
                            self.root = .root(context: .init(status: mastodonStatus))
                        }
                        self.loadThreadStateMachine.enter(LoadThreadState.Loading.self)
                        self.onEdit.send(mastodonStatus)
                    case .post:
                        self.loadThreadStateMachine.enter(LoadThreadState.Loading.self)
                    }
                }
            }
            .store(in: &disposeBag)
    }
    

}

extension ThreadViewModel {
    
    struct ThreadContext {
        let statusID: Mastodon.Entity.Status.ID
        let replyToID: Mastodon.Entity.Status.ID?
    }
    
}
