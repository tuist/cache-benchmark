//
//  PublisherService.swift
//  
//
//  Created by MainasuK on 2021-12-2.
//

import UIKit
import Combine

@MainActor
public final class PublisherService {
    
    public static let shared = { PublisherService() }()
    
    var disposeBag = Set<AnyCancellable>()
    
    @Published public private(set) var statusPublishers: [StatusPublisher] = []
    
    // output
    public let statusPublishResult = PassthroughSubject<Result<StatusPublishResult, Error>, Never>()

    var currentPublishProgressObservation: NSKeyValueObservation?
    @Published public var currentPublishProgress: Double = 0
    
    private init() {
        $statusPublishers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] publishers in
                guard let self = self else { return }
                
                self.currentPublishProgressObservation?.invalidate()
                
                guard let last = publishers.last else {
                    self.currentPublishProgressObservation = nil
                    self.currentPublishProgress = 0
                    return
                }
                
                self.currentPublishProgressObservation = last.progress
                    .observe(\.fractionCompleted, options: [.initial, .new]) { [weak self] progress, _ in
                        guard let self = self else { return }
                        Task { @MainActor in
                            self.currentPublishProgress = progress.fractionCompleted
                        }
                    }
            }
            .store(in: &disposeBag)
        
        statusPublishResult
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .success:
                    break
                    // TODO: update store review count trigger
                    // UserDefaults.shared.storeReviewInteractTriggerCount += 1
                case .failure:
                    // TODO: do not prompt for AppStore review until at least one successful publish has happened after this (IOS-35)
                    break
                }
            }
            .store(in: &disposeBag)
    }
    
}

extension PublisherService {
    
    @MainActor
    public func enqueue(statusPublisher publisher: StatusPublisher, authenticationBox: MastodonAuthenticationBox) {
        guard !statusPublishers.contains(where: { $0 === publisher }) else {
            assertionFailure()
            return
        }
        statusPublishers.append(publisher)
        
        Task {
            do {
                let result = try await publisher.publish(api: APIService.shared, authenticationBox: authenticationBox)
                
                self.statusPublishResult.send(.success(result))
                self.statusPublishers.removeAll(where: { $0 === publisher })
                
            } catch is CancellationError {
                self.statusPublishers.removeAll(where: { $0 === publisher })
                self.currentPublishProgress = 0
                self.statusPublishResult.send(.failure(CancellationError()))
            } catch {
                self.statusPublishers.removeAll(where: { $0 === publisher })
                self.statusPublishResult.send(.failure(error))
                self.currentPublishProgress = 0
            }
        }
    }
}
