import Foundation

/// Stores offers as JSON on this device so a created or accepted offer survives a relaunch.
/// Any unreadable file counts as absent: a schema change between builds must never stop the
/// app from launching.
struct OfferPersistence: Sendable {
    let fileURL: URL

    static var standard: OfferPersistence {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directory = base.appendingPathComponent("PfandWeitergeben", isDirectory: true)
        return OfferPersistence(fileURL: directory.appendingPathComponent("offers.json"))
    }

    func load() -> [Offer]? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([Offer].self, from: data)
    }

    func save(_ offers: [Offer]) {
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(offers).write(to: fileURL, options: .atomic)
        } catch {
            // Best effort: the in-memory state stays valid, the next mutation tries again.
        }
    }

    func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    /// Combines what was stored with the current demo seed. Demo offers nobody touched take the
    /// seed's fresh pickup windows; everything the person changed or created is kept as stored.
    static func merge(stored: [Offer], seed: [Offer]) -> [Offer] {
        let seedByID = Dictionary(uniqueKeysWithValues: seed.map { ($0.id, $0) })
        var merged = stored.map { offer -> Offer in
            if let fresh = seedByID[offer.id], offer.status == .open, fresh.status == .open { return fresh }
            return offer
        }
        let storedIDs = Set(stored.map(\.id))
        merged += seed.filter { !storedIDs.contains($0.id) }
        return merged
    }
}
