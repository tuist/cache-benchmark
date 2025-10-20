import Foundation

public struct WMFLanguage: Equatable, Codable, Sendable {
    public let languageCode: String
    public let languageVariantCode: String?
    
    public init(languageCode: String, languageVariantCode: String?) {
        self.languageCode = languageCode
        self.languageVariantCode = languageVariantCode
    }
}
