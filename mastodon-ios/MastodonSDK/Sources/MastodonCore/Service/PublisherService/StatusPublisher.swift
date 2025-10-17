//
//  StatusPublisher.swift
//  
//
//  Created by MainasuK on 2021-11-26.
//

import Foundation
import Combine

@MainActor
public protocol StatusPublisher: ProgressReporting {
    var state: Published<StatusPublisherState>.Publisher { get }
    var reactor: StatusPublisherReactor? { get set }
    func publish(api: APIService, authenticationBox: MastodonAuthenticationBox) async throws -> StatusPublishResult
}
