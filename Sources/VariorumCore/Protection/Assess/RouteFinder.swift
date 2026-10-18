import Foundation

// VX-378 U1 — WHAT OPENS A COPY, IN ONE SENTENCE (rule 4, `notes/CastleRules.md`;
// the rules' considered-and-not-pursued list: "the 'Opens with' route finder as
// a promise — reduced to one sentence: *your current passphrase or words; on
// this Mac, its quiet road if it still holds that key*"). Pure: facts in, the
// sentence's two halves out, keylessly, for each copy of this library:
//   - THE CURRENT SECRETS: the copy's key is the live key file's current key
//     or one its history holds — every key change carries that list forward
//     (rule 4), so the current passphrase or words open it;
//   - THIS MAC'S QUIET ROAD, if it still holds that key: a custody item for it
//     (Touch ID or silent), or an Apple key readable here that wraps it in a
//     key file the catalog serves the copy with. A quiet road opens only a key
//     it holds directly — it never reaches through the history (rule 4).
// (The road graph, its witness routes, the secrets' days and the anchor's
// roads left with VX-378 U1 — rule 4; promise 9 left with them.)

/// The custody items this scope holds (enumerated by name, whatever
/// fingerprint they name).
///
/// VX-390 — THE STAMP: each item also carries the ID of the library it was
/// made for (`libraryID` — a plain attribute beside the item, non-secret: the
/// key file already says it in the clear), so entering Castle can sweep THIS
/// library's silent items whatever the live key file or the catalogue still
/// remembers (rule 11 — the gate's seed 3: a Time Machine rollback put an
/// older key file back while the keychain kept the rolled-back stretch's
/// item). nil: an item that carries no stamp (rule 25's stated limit).
///
/// THE ITEM'S IDENTITY IS ITS NAME — `<scope>-<fingerprint16>-<class>` — so
/// equality and hashing read the fingerprint and the class only: a fact built
/// to ask "is there an item for this key of this class?" finds the item
/// whatever it is stamped with. The stamp is what the item SAYS, never which
/// item it is.
public struct CustodyItemFact: Hashable, Sendable {
    public var fingerprint: String
    public var itemClass: ProtectionNames.CustodyClass
    /// The library the item was made for (VX-390); nil = unstamped.
    public var libraryID: String?

    public init(fingerprint: String, itemClass: ProtectionNames.CustodyClass, libraryID: String? = nil) {
        self.fingerprint = fingerprint
        self.itemClass = itemClass
        self.libraryID = libraryID
    }

    public static func == (a: CustodyItemFact, b: CustodyItemFact) -> Bool {
        a.fingerprint == b.fingerprint && a.itemClass == b.itemClass
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(fingerprint)
        hasher.combine(itemClass)
    }
}

/// A quiet road this Mac holds to a key (rule 8's roads).
public enum QuietRoad: String, Hashable, Sendable {
    /// A Touch ID custody item.
    case touchID
    /// A silent custody item — anyone who can sign in to this Mac.
    case thisMac
    /// An Apple key readable here.
    case appleAccount
}

/// The one sentence for one copy: *your current passphrase or words; on this
/// Mac, its quiet road if it still holds that key.*
public struct OpensWith: Equatable, Sendable {
    /// The current passphrase or words open it (rule 4).
    public var currentSecrets: Bool
    /// The quiet roads this Mac still holds to its key.
    public var quietRoads: Set<QuietRoad>

    public init(currentSecrets: Bool, quietRoads: Set<QuietRoad> = []) {
        self.currentSecrets = currentSecrets
        self.quietRoads = quietRoads
    }

    public var opens: Bool { currentSecrets || !quietRoads.isEmpty }
}

/// What the sentence reads — all non-secret.
public struct RouteFacts: Sendable {
    public var catalog: Catalog
    /// The live key file's catalog id.
    public var liveKeyFileID: String?
    public var custody: [CustodyItemFact]
    /// Apple key ids readable here.
    public var readableAppleKeyIDs: Set<String>

    public init(
        catalog: Catalog, liveKeyFileID: String? = nil, custody: [CustodyItemFact] = [],
        readableAppleKeyIDs: Set<String> = []
    ) {
        self.catalog = catalog
        self.liveKeyFileID = liveKeyFileID ?? catalog.liveKeyFile?.id
        self.custody = custody
        self.readableAppleKeyIDs = readableAppleKeyIDs
    }
}

public struct RouteFinder: Sendable {
    public let facts: RouteFacts

    public init(_ facts: RouteFacts) {
        self.facts = facts
    }

    private var live: KeyFile? { facts.liveKeyFileID.flatMap { facts.catalog.keyFile(id: $0)?.document } }

    /// The keys the current passphrase or words reach: the live key file's
    /// current key and its history — when it has a typed lock at all.
    private var currentSecretsReach: Set<String> {
        guard let live, live.passphrase != nil || live.words != nil || live.masterWordsCopy != nil else { return [] }
        return Set(live.heldFingerprints)
    }

    /// The sentence for key `fingerprint`, `keyFiles` the files that might
    /// carry an Apple wrap of it (the copy's own; the live one is always read).
    public func opensWith(fingerprint: String, keyFiles: [KeyFile] = []) -> OpensWith {
        var roads = Set<QuietRoad>()
        for item in facts.custody where item.fingerprint == fingerprint {
            roads.insert(item.itemClass == .touchid ? .touchID : .thisMac)
        }
        for file in keyFiles + [live].compactMap({ $0 }) where file.fingerprint == fingerprint {
            if let wrap = file.apple, facts.readableAppleKeyIDs.contains(wrap.keyID) { roads.insert(.appleAccount) }
        }
        return OpensWith(currentSecrets: currentSecretsReach.contains(fingerprint), quietRoads: roads)
    }

    /// The sentence for a copy: its key's — or, when the catalog can't pin its
    /// key, only what holds for every key it could be under.
    public func opensWith(copy: CatalogCopy) -> OpensWith {
        let files = facts.catalog.servingKeyFiles(of: copy).compactMap(\.document)
        if let fingerprint = copy.fingerprint { return opensWith(fingerprint: fingerprint, keyFiles: files) }
        let each = copy.candidateFingerprints.map { opensWith(fingerprint: $0, keyFiles: files) }
        guard let first = each.first else { return OpensWith(currentSecrets: false) }
        return OpensWith(
            currentSecrets: each.allSatisfy(\.currentSecrets),
            quietRoads: each.dropFirst().reduce(first.quietRoads) { $0.intersection($1.quietRoads) })
    }
}
