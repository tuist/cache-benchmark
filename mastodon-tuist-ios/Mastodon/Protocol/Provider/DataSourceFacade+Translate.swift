//
//  DataSourceFacade+Translate.swift
//  Mastodon
//
//  Created by Marcus Kida on 29.11.22.
//

import UIKit
import CoreData
import CoreDataStack
import MastodonCore
import MastodonSDK

extension DataSourceFacade {
    enum TranslationFailure: Error {
        case emptyOrInvalidResponse
    }
    
    public static func translateStatus(
        provider: AuthContextProvider,
        status: MastodonStatus
    ) async throws -> Mastodon.Entity.Translation {
        FeedbackGenerator.shared.generate(.selectionChanged)

        do {
            let value = try await APIService.shared
                .translateStatus(
                    statusID: status.id,
                    authenticationBox: provider.authenticationBox
                ).value

            if let content = value.content, content.isNotEmpty {
                return value
            } else {
                throw TranslationFailure.emptyOrInvalidResponse
            }

        } catch {
            throw TranslationFailure.emptyOrInvalidResponse
        }
    }
}
