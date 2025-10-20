//
//  ProfileViewModel.swift
//  Mastodon
//
//  Created by MainasuK Cirno on 2021-3-29.
//

import UIKit
import Combine
import CoreDataStack
import MastodonSDK
import MastodonMeta
import MastodonAsset
import MastodonCore
import MastodonLocalization
import MastodonUI

enum ServerHostedImage: Equatable {
    case fetchable(URL)
    //    case fetching(URL)
    //    case fetched(URL, UIImage)
    //    case fetchError(URL, Error)
    case local(UIImage)
}

struct ProfileHeaderDetails: Equatable {
    let bannerImage: ServerHostedImage?
    let avatarImage: ServerHostedImage?
    let displayName: String?
    let bioText: String?
    
    init(_ account: Mastodon.Entity.Account) {
        bannerImage = account.headerImageURL().flatMap { .fetchable($0) }
        if let domain = account.domain {
            avatarImage = .fetchable(account.avatarImageURLWithFallback(domain: domain))
        } else {
            avatarImage = account.avatarImageURL().flatMap { .fetchable($0) } // TODO: there is a fallback option here.  what is it for?
        }
        displayName = account.displayNameWithFallback
        bioText = account.note
    }
    
    init(bannerImage: UIImage?, avatarImage: UIImage?, displayName: String?, bioText: String?) {
        self.bannerImage = bannerImage.flatMap{ .local($0) }
        self.avatarImage = avatarImage.flatMap{ .local($0) }
        self.displayName = displayName
        self.bioText = bioText
    }
}

struct ProfileAboutDetails {
    let createdAt: Date
    let fields: [ String : String ]
    
    init(_ account: Mastodon.Entity.Account) {
        createdAt = account.createdAt
        fields = profileFields(account)
    }
}

fileprivate func profileFields(_ account: Mastodon.Entity.Account) -> [ String : String ] {
    var result = [ String : String ]()
    for field in account.fields ?? [] {
        result[field.name] = field.value
    }
    return result
}

public struct ProfileViewModelImmutable {
    
    let profileType: ProfileViewController.ProfileType
    let state: ProfileInteractionState
    
    var headerDetails: ProfileHeaderDetails {
        return ProfileHeaderDetails(profileType.accountToDisplay)
    }
    var aboutDetails: ProfileAboutDetails {
        return ProfileAboutDetails(profileType.accountToDisplay)
    }
    
    public enum ProfileInteractionState {
        case idle
        case updating
        case editing
        case pushingEdits
        
        var actionButtonEnabled: Bool {
            switch self {
            case .updating, .pushingEdits:
                return false
            case .idle, .editing:
                return true
            }
        }
        
        var isEditing: Bool {
            switch self {
            case .editing, .pushingEdits:
                return true
            case .idle, .updating:
                return false
            }
        }
        
        var isUpdating: Bool {
            switch self {
            case .editing, .idle:
                return false
            case .pushingEdits, .updating:
                return true
            }
        }
    }
    
    var hideReplyBarButtonItem: Bool {
        return profileType.isMe
    }
    
    var hideMoreMenuBarButtonItem: Bool {
        return profileType.isMe
    }
    
    var hideIsMeBarButtonItems: Bool {
        return !profileType.isMe
    }
    
    var isPagingEnabled: Bool {
        guard !state.isEditing else { return false }
        guard let relationship = profileType.myRelationshipToDisplayedAccount else { return true }
        return !relationship.isBlockingOrBlocked
    }
}

fileprivate extension Mastodon.Entity.Relationship {
    var isBlockingOrBlocked: Bool {
        return blocking || blockedBy || domainBlocking
    }
}
