//
//  PrivacyViewModel.swift
//  Mastodon
//
//  Created by Nathan Mattes on 16.12.22.
//

import Foundation
import MastodonSDK
import MastodonLocalization
import SwiftUI

enum PolicySection {
    case termsOfService([PolicyRow])
    case privacy([PolicyRow])
    
    var title: String {
        switch self {
        case .termsOfService:
            return L10n.Scene.Privacy.termsOfServiceTitle
        case .privacy:
            return L10n.Scene.Privacy.title
        }
    }
    
    func description(_ domain: String) -> String? {
        switch self {
        case .termsOfService:
            return L10n.Scene.Privacy.termsOfServiceDescription(domain)
        case .privacy:
            return L10n.Scene.Privacy.description(domain)
        }
    }
}

class PolicyViewModel: ObservableObject {

    // input
    let domain: String
    let authenticateInfo: AuthenticationViewModel.AuthenticateInfo
    @Published var sections: [PolicySection]
    let instance: RegistrationInstance
    let applicationToken: Mastodon.Entity.Token
    let didAccept: ()->()

    init(
        domain: String,
        authenticateInfo: AuthenticationViewModel.AuthenticateInfo,
        instance: RegistrationInstance,
        applicationToken: Mastodon.Entity.Token,
        didAccept: @escaping ()->()
    ) {
        self.domain = domain
        self.authenticateInfo = authenticateInfo
        self.instance = instance
        self.applicationToken = applicationToken
        self.didAccept = didAccept
        self.sections = [
            .termsOfService([.serverTermsOfService(domain: domain, confirmedReachable: false)]),
            .privacy([.iosAppPrivacy, .serverPrivacy(domain: domain)])
        ]
        
        checkForTermsOfService(domain)
    }
    
    func checkForTermsOfService(_ domain: String) {
        guard let termsOfService = instance.termsOfService else { removeTermsOfServiceSection(); return }
        
        var request = URLRequest(url: termsOfService)
        request.httpMethod = "HEAD"
        URLSession(configuration: .default)
            .dataTask(with: request) { (_, response, error) -> Void in
                guard error == nil else {
                    self.removeTermsOfServiceSection()
                    return
                }
                
                guard (response as? HTTPURLResponse)?
                    .statusCode == 200 else {
                    self.removeTermsOfServiceSection()
                    return
                }
                
                self.sections = [
                    .termsOfService([.serverTermsOfService(domain: domain, confirmedReachable: true)]),
                    .privacy([.iosAppPrivacy, .serverPrivacy(domain: domain)])
                ]
            }
            .resume()
        
    }
    
    func removeTermsOfServiceSection() {
        sections = [
            .privacy([.iosAppPrivacy, .serverPrivacy(domain: domain)])
        ]
    }
}
