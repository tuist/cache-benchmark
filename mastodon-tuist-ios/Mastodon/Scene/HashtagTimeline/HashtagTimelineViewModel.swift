//
//  HashtagTimelineViewModel.swift
//  Mastodon
//
//  Created by BradGao on 2021/3/30.
//

import UIKit
import Combine
import CoreData
import CoreDataStack
import GameplayKit
import MastodonSDK
import MastodonCore

final class HashtagTimelineViewModel {

    let hashtag: String
    
    var disposeBag = Set<AnyCancellable>()
    
    var needLoadMiddleIndex: Int? = nil

    // input
    let authenticationBox: MastodonAuthenticationBox
    let dataController: StatusDataController
    let isFetchingLatestTimeline = CurrentValueSubject<Bool, Never>(false)
    let timelinePredicate = CurrentValueSubject<NSPredicate?, Never>(nil)
    let hashtagEntity = CurrentValueSubject<Mastodon.Entity.Tag?, Never>(nil)

    // output
    var diffableDataSource: UITableViewDiffableDataSource<StatusSection, MastodonItemIdentifier>?
    let didLoadLatest = PassthroughSubject<Void, Never>()
    let hashtagDetails = CurrentValueSubject<Mastodon.Entity.Tag?, Never>(nil)

    // bottom loader
    private(set) lazy var stateMachine: GKStateMachine = {
        // exclude timeline middle fetcher state
        let stateMachine = GKStateMachine(states: [
            State.Initial(viewModel: self),
            State.Reloading(viewModel: self),
            State.Fail(viewModel: self),
            State.Idle(viewModel: self),
            State.Loading(viewModel: self),
            State.NoMore(viewModel: self),
        ])
        stateMachine.enter(State.Initial.self)
        return stateMachine
    }()
    
    @MainActor
    init(authenticationBox: MastodonAuthenticationBox, hashtag: String) {
        self.authenticationBox = authenticationBox
        self.hashtag = hashtag
        self.dataController = StatusDataController()
        updateTagInformation()
        // end init
    }
    
    func viewWillAppear() {
        hashtagDetails.send(hashtagDetails.value?.copy(following: hashtagEntity.value?.following ?? false))
    }
}

extension HashtagTimelineViewModel {
    func followTag() {
        self.hashtagDetails.send(hashtagDetails.value?.copy(following: true))
        Task { @MainActor in
            let tag = try? await APIService.shared.followTag(
                for: hashtag,
                authenticationBox: authenticationBox
            ).value
            self.hashtagDetails.send(tag)
        }
    }
    
    func unfollowTag() {
        self.hashtagDetails.send(hashtagDetails.value?.copy(following: false))
        Task { @MainActor in
            let tag = try? await APIService.shared.unfollowTag(
                for: hashtag,
                authenticationBox: authenticationBox
            ).value
            self.hashtagDetails.send(tag)
        }
    }
}

private extension HashtagTimelineViewModel {
    func updateTagInformation() {
        Task { @MainActor in
            let tag = try? await APIService.shared.getTagInformation(
                for: hashtag,
                authenticationBox: authenticationBox
            ).value
            
            self.hashtagDetails.send(tag)
        }
    }
}
