import Foundation
import PocketCastsDataModel
import PocketCastsServer
import PocketCastsUtils

extension PodcastManager {
    func unsubscribe(podcast: Podcast) {
        let savedFolderUuid = podcast.folderUuid

        if SyncManager.isUserLoggedIn() {
            // if the user has signed in, there's a cleanup task (PodcastManager.deletePodcastIfUnused) that will run later to remove episodes they haven't interacted but we do some basic cleanup here
            // eg: remove downloaded/queued episodes and remove any that are in Up Next
            podcast.folderUuid = nil
            podcast.subscribed = 0
            podcast.autoArchiveEpisodeLimit = 0
            podcast.autoDownloadSetting = AutoDownloadSetting.off.rawValue
            podcast.isPushEnabled = false
            podcast.syncStatus = SyncStatus.notSynced.rawValue
            podcast.autoAddToUpNext = AutoAddToUpNextSetting.off.rawValue
            podcast.settings = PodcastSettings.defaults
            dataManager.save(podcast: podcast)
        } else {
            // if they aren't signed in, just blow it all away
            EpisodeManager.deleteAllEpisodesInPodcast(id: podcast.id)
            dataManager.delete(podcast: podcast)
        }

        PlaylistManager.handlePodcastUnsubscribed(podcastUuid: podcast.uuid)

        // additionally if this podcast was in a folder, update the folder
        if let folderUuid = savedFolderUuid {
            dataManager.updateFolderSyncModified(folderUuid: folderUuid, syncModified: TimeFormatter.currentUTCTimeInMillis())
            NotificationCenter.postOnMainThread(notification: Constants.Notifications.folderChanged, object: folderUuid)
        }

        NotificationCenter.postOnMainThread(notification: Constants.Notifications.podcastDeleted, object: podcast.uuid)
    }
}
