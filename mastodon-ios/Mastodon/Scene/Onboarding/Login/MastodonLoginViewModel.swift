//
//  MastodonLoginViewModel.swift
//  Mastodon
//
//  Created by Nathan Mattes on 11.11.22.
//

import Foundation
import MastodonSDK
import MastodonCore
import Combine

protocol MastodonLoginViewModelDelegate: AnyObject {
  func serversUpdated(_ viewModel: MastodonLoginViewModel)
}

@MainActor
class MastodonLoginViewModel {

  private var serverList: [Mastodon.Entity.Server] = []
  var filteredServers: [Mastodon.Entity.Server] = []

  weak var delegate: MastodonLoginViewModelDelegate?
  var disposeBag = Set<AnyCancellable>()

  func updateServers() {
      APIService.shared.servers(registrations: "all").sink(receiveCompletion: { [weak self] completion in
      switch completion {
        case .finished:
          guard let self = self else { return }

          self.delegate?.serversUpdated(self)
        case .failure(let error):
          print(error)
      }
    }, receiveValue: { content in
      let servers = content.value
      self.serverList = servers
    }).store(in: &disposeBag)
  }

  func filterServers(withText query: String?) {
    guard let query else {
      filteredServers = serverList
      delegate?.serversUpdated(self)
      return
    }

    filteredServers = serverList.filter { $0.domain.lowercased().contains(query) }.sorted {$0.totalUsers > $1.totalUsers }
    delegate?.serversUpdated(self)
  }
}
