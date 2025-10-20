//
//  APIService+Settings.swift
//  Mastodon
//
//  Created by ihugo on 2021/4/9.
//

import Combine
import CoreData
import CoreDataStack
import Foundation
import MastodonSDK

extension APIService {
 
    public func subscribeToPushNotifications(
        subscriptionObjectID: NSManagedObjectID,
        query: Mastodon.API.Subscriptions.CreateSubscriptionQuery,
        mastodonAuthenticationBox: MastodonAuthenticationBox
    ) async throws -> Mastodon.Entity.Subscription {
        let authorization = mastodonAuthenticationBox.userAuthorization
        let domain = mastodonAuthenticationBox.domain
        
        let responseContent = try await Mastodon.API.Subscriptions.createSubscription(
            session: session,
            domain: domain,
            authorization: authorization,
            query: query
        )
        
        let newSubscription = responseContent.value
        let managedObjectContext = self.backgroundManagedObjectContext
        try await managedObjectContext.performChanges {
            guard let subscription = managedObjectContext.object(with: subscriptionObjectID) as? NotificationSubscription else {
                assertionFailure()
                return
            }
            subscription.alert.update(favourite: newSubscription.alerts.favourite)
            subscription.alert.update(reblog: newSubscription.alerts.reblog)
            subscription.alert.update(follow: newSubscription.alerts.follow)
            subscription.alert.update(mention: newSubscription.alerts.mention)
            
            subscription.endpoint = newSubscription.endpoint
            subscription.serverKey = newSubscription.serverKey
            subscription.userToken = authorization.accessToken
            subscription.didUpdate(at: responseContent.networkDate)
        }
        return newSubscription
    }
    
    func cancelSubscription(
        domain: String,
        authorization: Mastodon.API.OAuth.Authorization
    ) async throws -> Mastodon.Response.Content<Mastodon.Entity.EmptySubscription> {
        let response = try await Mastodon.API.Subscriptions.removeSubscription(
            session: session,
            domain: domain,
            authorization: authorization
        ).singleOutput()
        
        return response
    }

}

