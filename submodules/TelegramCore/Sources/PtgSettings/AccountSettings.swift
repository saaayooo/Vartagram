import Foundation
import Postbox

extension ApplicationSpecificPreferencesKeys {
    public static let ptgAccountSettings = applicationSpecificPreferencesKey(100)
}

public struct PtgAccountSettings: Codable, Equatable {
    public let ignoreAllContentRestrictions: Bool
    public let skipSetTyping: Bool
    public let ghostModeRead: Bool
    public let ghostModeStories: Bool
    public let ghostModeOnline: Bool
    
    public static var `default`: PtgAccountSettings {
        return PtgAccountSettings(
            ignoreAllContentRestrictions: false,
            skipSetTyping: false,
            ghostModeRead: false,
            ghostModeStories: false,
            ghostModeOnline: false
        )
    }
    
    public init(
        ignoreAllContentRestrictions: Bool,
        skipSetTyping: Bool,
        ghostModeRead: Bool = false,
        ghostModeStories: Bool = false,
        ghostModeOnline: Bool = false
    ) {
        self.ignoreAllContentRestrictions = ignoreAllContentRestrictions
        self.skipSetTyping = skipSetTyping
        self.ghostModeRead = ghostModeRead
        self.ghostModeStories = ghostModeStories
        self.ghostModeOnline = ghostModeOnline
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)
        
        self.ignoreAllContentRestrictions = (try container.decodeIfPresent(Int32.self, forKey: "iacr") ?? 0) != 0
        self.skipSetTyping = (try container.decodeIfPresent(Int32.self, forKey: "sst") ?? 0) != 0
        self.ghostModeRead = (try container.decodeIfPresent(Int32.self, forKey: "gmr") ?? 0) != 0
        self.ghostModeStories = (try container.decodeIfPresent(Int32.self, forKey: "gms") ?? 0) != 0
        self.ghostModeOnline = (try container.decodeIfPresent(Int32.self, forKey: "gmo") ?? 0) != 0
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        
        try container.encode((self.ignoreAllContentRestrictions ? 1 : 0) as Int32, forKey: "iacr")
        try container.encode((self.skipSetTyping ? 1 : 0) as Int32, forKey: "sst")
        try container.encode((self.ghostModeRead ? 1 : 0) as Int32, forKey: "gmr")
        try container.encode((self.ghostModeStories ? 1 : 0) as Int32, forKey: "gms")
        try container.encode((self.ghostModeOnline ? 1 : 0) as Int32, forKey: "gmo")
    }
    
    public init(_ entry: PreferencesEntry?) {
        self = entry?.get(PtgAccountSettings.self) ?? .default
    }
    
    public init(_ transaction: Transaction) {
        let entry = transaction.getPreferencesEntry(key: ApplicationSpecificPreferencesKeys.ptgAccountSettings)
        self.init(entry)
    }
}
