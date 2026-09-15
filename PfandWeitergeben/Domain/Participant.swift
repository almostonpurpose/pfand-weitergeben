import Foundation

/// Someone taking part in a hand-over. There is no account behind it: the person on this device
/// gets a random identifier on first use plus a display name chosen in Settings. A later backend
/// maps this identifier to an authenticated actor without changing the flow.
struct Participant: Codable, Hashable, Sendable {
    var id: String
    var name: String

    var isMe: Bool { id == LocalIdentity.id }

    /// What the UI shows: "Du" for the person on this device, the chosen name for others,
    /// and a neutral fallback if a name was left empty.
    var displayName: String {
        if isMe { return L10n.string("actor.you") }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.string("actor.neighbour") : trimmed
    }
}

enum LocalIdentity {
    static let idKey = "localParticipantID"
    static let displayNameKey = "displayName"

    /// Created once, kept in UserDefaults, never shown to anyone.
    static var id: String {
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: idKey), !existing.isEmpty { return existing }
        let fresh = UUID().uuidString
        defaults.set(fresh, forKey: idKey)
        return fresh
    }

    static var displayName: String {
        (UserDefaults.standard.string(forKey: displayNameKey) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var participant: Participant { Participant(id: id, name: displayName) }
}

/// Four digits the collector knows and names at the door. Entering them is what moves an offer
/// to "collected", so a hand-over needs both sides, or the collector confirming a contactless
/// pickup with the code they were given.
enum HandoverCode {
    static func generate() -> String {
        String(format: "%04d", Int.random(in: 0...9999))
    }

    static func matches(_ entered: String, _ expected: String?) -> Bool {
        guard let expected else { return false }
        return entered.trimmingCharacters(in: .whitespacesAndNewlines) == expected
    }
}
