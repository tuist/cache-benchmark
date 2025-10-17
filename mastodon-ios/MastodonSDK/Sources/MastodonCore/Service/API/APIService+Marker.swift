//
//  APIService+Marker.swift
//  MastodonSDK
//
//  Created by Shannon Hughes on 2/24/25.
//

import MastodonSDK

extension APIService {
    
    public func lastReadMarkers(
        authenticationBox: MastodonAuthenticationBox
    ) async throws -> Mastodon.Entity.Marker {
        let domain = authenticationBox.domain
        let authorization = authenticationBox.userAuthorization

        let response = try await Mastodon.API.Marker.lastReadMarkers(domain: domain, session: session, authorization: authorization)

        return response
    }
}
