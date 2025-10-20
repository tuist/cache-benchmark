import Foundation
import PocketCastsDataModel
import PocketCastsUtils
import SwiftProtobuf

class SubscriptionStatusTask: ApiBaseTask {
    var completion: ((Bool) -> Void)?

    override func apiTokenAcquired(token: String) {
        let url = ServerConstants.Urls.api() + "subscription/status"
        do {
            let (response, httpStatus) = getToServer(url: url, token: token)

            guard let responseData = response, httpStatus?.statusCode == ServerConstants.HttpConstants.ok else {
                FileLog.shared.addMessage("Subscription status failed \(httpStatus?.statusCode ?? -1)")
                completion?(false)
                return
            }
            do {
                let status = try Api_SubscriptionsStatusResponse(serializedData: responseData)
                let originalSubscriptionStatus = SubscriptionHelper.hasActiveSubscription()
                SubscriptionHelper.setSubscriptionPaid(Int(status.paid))
                SubscriptionHelper.setSubscriptionPlatform(Int(status.platform))
                SubscriptionHelper.setSubscriptionExpiryDate(status.expiryDate.timeIntervalSince1970)
                SubscriptionHelper.setSubscriptionAutoRenewing(status.autoRenewing)
                SubscriptionHelper.setSubscriptionGiftDays(Int(status.giftDays))
                SubscriptionHelper.setSubscriptionFrequency(Int(status.frequency))
                SubscriptionHelper.setSubscriptionType(Int(status.type))
                SubscriptionHelper.subscriptionTier = SubscriptionTier(rawValue: status.tier) ?? .none

                SubscriptionHelper.shouldRemoveBannerAd = status.features.removeBannerAds
                SubscriptionHelper.shouldRemoveDiscoverAds = status.features.removeDiscoverAds
                SubscriptionHelper.setSubscriptionCreateDate(status.createdAt.timeIntervalSince1970)

                NotificationCenter.default.post(name: ServerNotifications.subscriptionStatusChanged, object: nil)

                var expiryDateString = "nil"
                if let expiryDate = SubscriptionHelper.subscriptionRenewalDate() {
                    expiryDateString = expiryDate.description
                }
                var createDateString = "nil"
                if let createDate = SubscriptionHelper.subscriptionCreateDate() {
                    createDateString = createDate.description
                }
                FileLog.shared.addMessage("Received subscription status paid : \(status.paid), platform : \(status.platform), frequency : \(status.frequency), giftDays : \(status.giftDays), createDate: \(createDateString), expiryDate : \(expiryDateString), autoRenewing : \(status.autoRenewing), timeToSubscriptionExpiry: \(SubscriptionHelper.timeToSubscriptionExpiry() ?? 0), originalSubscriptionStatus: \(originalSubscriptionStatus), shouldRemoveBannerAd: \(status.features.removeBannerAds), shouldRemoveDiscoverAds: \(status.features.removeDiscoverAds)")
                if originalSubscriptionStatus, !SubscriptionHelper.hasActiveSubscription() {
                    ServerConfig.shared.syncDelegate?.cleanupCloudOnlyFiles()
                }
                completion?(true)
            }
        } catch {
            FileLog.shared.addMessage("SubscriptionStatusTask: Protobuf Encoding failed \(error.localizedDescription)")
            completion?(false)
        }
    }

    /* Unused old code, leaving for now */
    private func processPodcastSubscriptions(status: Api_SubscriptionsStatusResponse) {
        var podcastSubscriptions = [PodcastSubscription]()

        for subscription in status.subscriptions {
            if subscription.type == SubscriptionType.supporter.rawValue {
                for podcastUuids in subscription.podcasts {
                    let podcastSubscription = PodcastSubscription(uuid: podcastUuids.userPodcastUuid, masterUuid: podcastUuids.masterPodcastUuid, bundleUuid: subscription.bundleUuid, frequency: Int(subscription.frequency), expiryDate: subscription.expiryDate.timeIntervalSince1970, autoRenewing: subscription.autoRenewing, platform: Int(subscription.platform))
                    podcastSubscriptions.append(podcastSubscription)
                }
            }
        }

        if podcastSubscriptions.count > 0 {
            SubscriptionHelper.setSubscriptionPodcasts(podcastSubscriptions)
        }
    }
}
