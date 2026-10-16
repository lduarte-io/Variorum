import Foundation

// VX-305 U2 — THE ROUTE FINDER (design §3.7, §3.11): for a copy under key K,
// every road to K, in plain words — the ONLY source of any sentence about what
// opens a copy (one *Opens with* line per copy: the restore list, the offer,
// the confirm, Data Safety and the field guide all read it). The roads:
//   - the copy's own key file;
//   - the live key file's history;
//   - the live key file's anchor, with the passphrase or the words of its day;
//   - any key file the catalog knows that holds K — as its current key, in its
//     history, or in its anchor (a kept anchor beside its history included);
//   - a custody item for K;
//   - an Apple wrap whose key is readable here (this Mac's own, another of the
//     account's);
//   - the current master's wrap (synced), proven current.
//
// Every road verifies itself (a key that doesn't open the file opens
// nothing); this finder only NAMES roads, keylessly, from non-secret facts —
// and names a road only where the facts PROVE it opens (promise 9: every road
// an *Opens with* line names opens the copy). A secret's DAY is how a line
// stays true without the secret in hand:
//   - `.current` — the passphrase or words that open the live key file's own
//     lock: a passphrase lock under the live file's KDF descriptor (a fresh
//     salt is minted for every new passphrase, so an equal descriptor is the
//     same passphrase — the executor's invariant, hand-forwarded to U3), a
//     words lock byte-identical to the live file's (RFC 3394 is
//     deterministic: the same key under the same words), a master words copy
//     byte-identical to the vault's current recovery wrap (§3.5a);
//   - `.of(day)` — the one TYPED at an act that day and verified there: an
//     anchor's own locks ("the passphrase or words you had on 12 October");
//   - `.heldHere(until:)` — what this Mac held its library under then: a
//     frozen key file's own locks, and a follower anchor's COPIED locks —
//     which may be older than that day's secret (a passphrase changed
//     elsewhere and never typed there — §8's residue).
// Pure: facts in, routes out. Each named opener carries a WITNESS route — the
// exact locks to walk — so a test (and U4's promise 9) can open the copy by
// it with the real secret.

/// When a secret was the one a lock was made under.
public enum SecretDay: Hashable, Sendable {
    case current
    case of(Date)
    case heldHere(until: Date?)

    /// Which of two days a line should name: the current secret first, then
    /// the most recent day, then a copied lock's.
    static func prefers(_ a: SecretDay, over b: SecretDay) -> Bool {
        switch (a, b) {
        case (.current, .current): return false
        case (.current, _): return true
        case (_, .current): return false
        case (.of(let x), .of(let y)): return x > y
        case (.of, .heldHere): return true
        case (.heldHere, .of): return false
        case (.heldHere(let x), .heldHere(let y)): return (x ?? .distantPast) > (y ?? .distantPast)
        }
    }
}

/// One thing that opens a copy — what an *Opens with* line names (§3.11).
public enum Opener: Hashable, Sendable {
    /// A Touch ID custody item on this Mac.
    case touchID
    /// A silent custody item: anyone who can sign in to this Mac (rule 3).
    case thisMac
    case passphrase(SecretDay)
    case words(SecretDay)
    /// The account's current master, online — the passphrase or words
    /// through the vault.
    case accountOnline
    /// An Apple key readable here — the Apple account.
    case appleAccount
    /// An Apple key this Mac lists as its own and can't read — one left in
    /// an Apple account this Mac no longer uses (§3.1 rule 2's last stated
    /// exception), or one iCloud Keychain hasn't carried here; Variorum can't
    /// tell which (corner 46).
    case appleKeyNotReadableHere

    /// Is this a secret she holds (rather than a device or an account)?
    public var isSecret: Bool {
        switch self {
        case .passphrase, .words, .accountOnline: return true
        default: return false
        }
    }

    /// Does this road run through an Apple account?
    public var isApple: Bool {
        switch self {
        case .appleAccount, .appleKeyNotReadableHere: return true
        default: return false
        }
    }

    /// The line's fixed order.
    var rank: Int {
        switch self {
        case .touchID: return 0
        case .thisMac: return 1
        case .passphrase: return 2
        case .words: return 3
        case .accountOnline: return 4
        case .appleAccount: return 5
        case .appleKeyNotReadableHere: return 6
        }
    }
}

/// A named anchor: the key file it rides in, and which one (nil = the file's
/// anchor; n = its n-th kept anchor).
public struct AnchorRef: Hashable, Sendable {
    public var keyFile: String
    public var kept: Int?
}

public enum AnchorLockRoad: String, Hashable, Sendable {
    case passphrase
    case words
}

/// One lock walked on a road.
public enum RouteStep: Hashable, Sendable {
    /// A custody item holds the key raw.
    case custody(fingerprint: String, itemClass: ProtectionNames.CustodyClass)
    /// A key file's lock opens its current key.
    case keyFileLock(keyFile: String, road: KeyFileRoad)
    /// A key file's current key opens an older key in its history.
    case history(keyFile: String, fingerprint: String)
    /// An anchor opens by its own lock (a secret of its day).
    case anchorLock(AnchorRef, AnchorLockRoad)
    /// A follower's anchor opens with its outgoing Castle key.
    case anchorOutgoingKey(AnchorRef)
    /// The outgoing key opens by a lock copied beside it (a follower's).
    case copiedLock(AnchorRef, KeyFileRoad)
    /// An opened anchor yields a key it holds directly.
    case anchorHolds(AnchorRef, fingerprint: String)
}

/// A road: the opener, and the locks from it to the key.
public struct Route: Hashable, Sendable {
    public var opener: Opener
    public var steps: [RouteStep]
}

/// What opens a copy (or a key): a witness road per opener, and the line.
public struct OpensWith: Equatable, Sendable {
    /// One witness road per opener, shortest found (per candidate key, for a
    /// copy the catalog can't pin).
    public var routes: [Route]

    public var openers: Set<Opener> { Set(routes.map(\.opener)) }
    public var opens: Bool { !routes.isEmpty }

    /// THE *OPENS WITH* LINE as typed reasons (phase 5 renders the words):
    /// each kind of opener once, a secret named by its best day.
    public var line: [Opener] {
        var best: [Int: Opener] = [:]
        for opener in openers {
            if let held = best[opener.rank] {
                switch (opener, held) {
                case (.passphrase(let a), .passphrase(let b)), (.words(let a), .words(let b)):
                    if SecretDay.prefers(a, over: b) { best[opener.rank] = opener }
                default: break
                }
            } else {
                best[opener.rank] = opener
            }
        }
        return best.keys.sorted().compactMap { best[$0] }
    }

    public func route(for opener: Opener) -> Route? { routes.first { $0.opener == opener } }

    /// Only the roads every candidate shares (a copy whose key the catalog
    /// can't pin — each named opener opens whichever it is under), with a
    /// witness road to EACH candidate.
    static func intersection(_ all: [OpensWith]) -> OpensWith {
        guard var shared = all.first?.openers else { return OpensWith(routes: []) }
        for other in all.dropFirst() { shared.formIntersection(other.openers) }
        return OpensWith(routes: all.flatMap { $0.routes.filter { shared.contains($0.opener) } })
    }
}

/// The custody items this scope holds (enumerated by name, whatever
/// fingerprint they name; a legacy per-library-ID silent item counts by the
/// fingerprint of the key it holds — a non-prompting read).
public struct CustodyItemFact: Hashable, Sendable {
    public var fingerprint: String
    public var itemClass: ProtectionNames.CustodyClass

    public init(fingerprint: String, itemClass: ProtectionNames.CustodyClass) {
        self.fingerprint = fingerprint
        self.itemClass = itemClass
    }
}

/// What the route finder reads — all non-secret.
public struct RouteFacts: Sendable {
    public var catalog: Catalog
    /// The live key file's catalog id — the one whose own locks are
    /// `.current` (the format-3 file beside the slot; before the migration,
    /// today's current file).
    public var liveKeyFileID: String?
    public var custody: [CustodyItemFact]
    /// Apple key ids readable here (this Mac's own, the account's, another
    /// Mac's carried by iCloud Keychain).
    public var readableAppleKeyIDs: Set<String>
    /// Ids this Mac's device section lists as its own and not retired, that
    /// it can't read.
    public var ownAppleKeyIDsNotReadableHere: Set<String>
    /// The account's current recovery wrap (the master under the words),
    /// from a vault read this session — what proves a key file's master
    /// current (§3.5a's copy is that wrap byte for byte).
    public var vaultRecoveryWrap: Data?
    /// Signed in to the account that vault is (the master road is online).
    public var signedInToVault: Bool

    public init(
        catalog: Catalog, liveKeyFileID: String? = nil, custody: [CustodyItemFact] = [],
        readableAppleKeyIDs: Set<String> = [],
        ownAppleKeyIDsNotReadableHere: Set<String> = [], vaultRecoveryWrap: Data? = nil,
        signedInToVault: Bool = false
    ) {
        self.catalog = catalog
        self.liveKeyFileID = liveKeyFileID ?? catalog.liveKeyFile?.id
        self.custody = custody
        self.readableAppleKeyIDs = readableAppleKeyIDs
        self.ownAppleKeyIDsNotReadableHere = ownAppleKeyIDsNotReadableHere
        self.vaultRecoveryWrap = vaultRecoveryWrap
        self.signedInToVault = signedInToVault
    }
}

public struct RouteFinder: Sendable {
    public let facts: RouteFacts
    /// The best road per opener, per node, computed once.
    private let reach: [Node: [Opener: [RouteStep]]]

    enum Node: Hashable, Sendable {
        case key(String)
        case anchor(AnchorRef)
    }

    public init(_ facts: RouteFacts) {
        self.facts = facts
        self.reach = Self.solve(facts)
    }

    /// What opens key `fingerprint`.
    public func opensWith(fingerprint: String) -> OpensWith {
        let routes = (reach[.key(fingerprint)] ?? [:])
            .map { Route(opener: $0.key, steps: $0.value) }
            .sorted { ($0.opener.rank, $0.steps.count) < ($1.opener.rank, $1.steps.count) }
        return OpensWith(routes: routes)
    }

    /// What opens a copy: its key's roads — or, when the catalog can't pin
    /// its key, only the roads every candidate key shares.
    public func opensWith(copy: CatalogCopy) -> OpensWith {
        if let fingerprint = copy.fingerprint { return opensWith(fingerprint: fingerprint) }
        let candidates = copy.candidateFingerprints.map { opensWith(fingerprint: $0) }
        return OpensWith.intersection(candidates)
    }

    // MARK: - The graph

    private struct Edge {
        var from: Node
        var step: RouteStep
        var to: Node
    }

    private struct Source {
        var opener: Opener
        var step: RouteStep
        var to: Node
    }

    private static func solve(_ facts: RouteFacts) -> [Node: [Opener: [RouteStep]]] {
        var sources: [Source] = []
        var edges: [Node: [Edge]] = [:]
        func edge(_ from: Node, _ step: RouteStep, _ to: Node) {
            edges[from, default: []].append(Edge(from: from, step: step, to: to))
        }
        let live = facts.liveKeyFileID.flatMap { facts.catalog.keyFile(id: $0) }
        let livePassphraseKDF: PassphraseKDF.Descriptor? = live?.document?.passphrase?.kdf
        let liveWordsLock: (fingerprint: String, blob: Data)? = live?.document.flatMap { file in
            file.words.map { (file.fingerprint, $0) }
        }

        // The secret a frozen key file's lock was made under: what this Mac
        // held its library under on the file's day — the account's that day
        // only if this Mac was up to date (a passphrase changed elsewhere and
        // never typed here is §8's residue), so never `.of(day)`, which an
        // anchor's own locks earn by being typed and verified at the act.
        func passphraseDay(_ kdf: PassphraseKDF.Descriptor, frozenAt: Date?, isLive: Bool) -> SecretDay {
            if isLive || kdf == livePassphraseKDF { return .current }
            return .heldHere(until: frozenAt)
        }
        func wordsDay(fingerprint: String, blob: Data, frozenAt: Date?, isLive: Bool) -> SecretDay {
            if isLive { return .current }
            if let liveWordsLock, liveWordsLock.fingerprint == fingerprint, liveWordsLock.blob == blob { return .current }
            return .heldHere(until: frozenAt)
        }
        func masterWordsDay(_ copy: Data, frozenAt: Date?) -> SecretDay {
            if let vault = facts.vaultRecoveryWrap, vault == copy { return .current }
            return .heldHere(until: frozenAt)
        }
        func appleOpener(_ id: String) -> Opener? {
            if facts.readableAppleKeyIDs.contains(id) { return .appleAccount }
            if facts.ownAppleKeyIDsNotReadableHere.contains(id) { return .appleKeyNotReadableHere }
            return nil
        }

        // Custody items.
        for item in facts.custody {
            sources.append(Source(
                opener: item.itemClass == .touchid ? .touchID : .thisMac,
                step: .custody(fingerprint: item.fingerprint, itemClass: item.itemClass),
                to: .key(item.fingerprint)))
        }

        for file in facts.catalog.keyFiles {
            let isLive = file.id == live?.id
            switch file.document {
            case let keyFile?:
                let current = Node.key(keyFile.fingerprint)
                func lock(_ opener: Opener?, _ road: KeyFileRoad) {
                    guard let opener else { return }
                    sources.append(Source(opener: opener, step: .keyFileLock(keyFile: file.id, road: road), to: current))
                }
                if let wrap = keyFile.passphrase {
                    lock(.passphrase(passphraseDay(wrap.kdf, frozenAt: file.frozenAt, isLive: isLive)), .passphrase)
                }
                if let blob = keyFile.words {
                    lock(.words(wordsDay(fingerprint: keyFile.fingerprint, blob: blob, frozenAt: file.frozenAt,
                                         isLive: isLive)), .words)
                }
                if keyFile.master != nil, let copy = keyFile.masterWordsCopy {
                    lock(.words(masterWordsDay(copy, frozenAt: file.frozenAt)), .masterThroughWords)
                    if facts.signedInToVault, let vault = facts.vaultRecoveryWrap, vault == copy {
                        lock(.accountOnline, .master)
                    }
                }
                if let apple = keyFile.apple { lock(appleOpener(apple.keyID), .apple) }
                for entry in keyFile.history {
                    edge(current, .history(keyFile: file.id, fingerprint: entry.fingerprint), .key(entry.fingerprint))
                }
                let anchors: [(AnchorRef, CastleAnchor)] = [keyFile.anchor.map { (AnchorRef(keyFile: file.id, kept: nil), $0) }]
                    .compactMap { $0 }
                    + keyFile.keptAnchors.enumerated().map { (AnchorRef(keyFile: file.id, kept: $0.offset), $0.element) }
                for (ref, anchor) in anchors {
                    let node = Node.anchor(ref)
                    let locks = anchor.locks
                    if let wrap = locks.passphrase {
                        let day: SecretDay = wrap.kdf == livePassphraseKDF ? .current : .of(anchor.madeAt)
                        sources.append(Source(opener: .passphrase(day), step: .anchorLock(ref, .passphrase), to: node))
                    }
                    if locks.words != nil {
                        sources.append(Source(opener: .words(.of(anchor.madeAt)), step: .anchorLock(ref, .words), to: node))
                    }
                    let outgoing = Node.key(anchor.outgoingFingerprint)
                    if locks.outgoingKey != nil {
                        edge(outgoing, .anchorOutgoingKey(ref), node)
                        let copied = locks.copiedLocks
                        if let wrap = copied?.passphrase {
                            let day: SecretDay = wrap.kdf == livePassphraseKDF ? .current : .heldHere(until: anchor.madeAt)
                            sources.append(Source(opener: .passphrase(day), step: .copiedLock(ref, .passphrase), to: outgoing))
                        }
                        if copied?.words != nil {
                            sources.append(Source(
                                opener: .words(.heldHere(until: anchor.madeAt)), step: .copiedLock(ref, .words), to: outgoing))
                        }
                        if copied?.master != nil, let copy = copied?.masterWordsCopy {
                            let day: SecretDay = facts.vaultRecoveryWrap == copy ? .current : .heldHere(until: anchor.madeAt)
                            sources.append(Source(
                                opener: .words(day), step: .copiedLock(ref, .masterThroughWords), to: outgoing))
                        }
                    }
                    for held in anchor.directFingerprints {
                        edge(node, .anchorHolds(ref, fingerprint: held), .key(held))
                    }
                }
            case nil:
                continue
            }
        }

        // The fixpoint: the shortest road per (node, opener).
        var best: [Node: [Opener: [RouteStep]]] = [:]
        var queue: [(node: Node, opener: Opener, steps: [RouteStep])] = []
        for source in sources {
            let steps = [source.step]
            if let held = best[source.to]?[source.opener], held.count <= steps.count { continue }
            best[source.to, default: [:]][source.opener] = steps
            queue.append((source.to, source.opener, steps))
        }
        var index = 0
        while index < queue.count {
            let (node, opener, steps) = queue[index]
            index += 1
            guard best[node]?[opener] == steps else { continue }
            for next in edges[node] ?? [] {
                let candidate = steps + [next.step]
                if let held = best[next.to]?[opener], held.count <= candidate.count { continue }
                best[next.to, default: [:]][opener] = candidate
                queue.append((next.to, opener, candidate))
            }
        }
        return best
    }
}

// MARK: - The sentences a door that replaces a secret says (§3.9)

/// The doors that replace a secret while an anchor exists (§3.9).
public enum SecretReplacingDoor: String, Sendable, CaseIterable {
    /// New words, Replace All Keys, a leave from an account, sync setup's
    /// choice to make new words — every door that replaces the words.
    case replacesWords
    case changePassphrase
    /// Standard's reset road for a forgotten passphrase.
    case resetForgottenPassphrase
    /// Use Castle that can't fold the anchor in (the secrets changed since
    /// the leave): the anchor stays beside the history, unchanged.
    case useCastleCannotFold
}

/// **One sentence, from the route finder, for this device's anchor and its
/// day** (§3.9): what still opens the copies from before the leave. Typed —
/// phase 4 renders the words.
public struct AnchorSentence: Equatable, Sendable {
    public var door: SecretReplacingDoor
    /// The day of the leave.
    public var day: Date
    /// What still opens those copies: never the passphrase she said she
    /// forgot (the reset road), never a road the anchor doesn't have (a
    /// words-only follower's names the words) — §3.9's closing sentence.
    public var stillOpensWith: [Opener]
    /// Whether the secret this door replaces provably opens the anchor (true:
    /// the passphrase being changed is the anchor's — its lock is under the
    /// live file's descriptor). Nil where that can't be told keylessly: the
    /// words (RFC 3394 locks under different keys never compare), and the
    /// doors that name no replaced secret. Where it isn't true, the sentence
    /// names the day's secret ("the words you had on 12 October") rather than
    /// "the one you're replacing" — always true (hand-forward to phase 4).
    public var replacedSecretOpensIt: Bool?
}

extension RouteFinder {
    /// This device's anchor (the live key file's), when there is one.
    public var liveAnchor: (ref: AnchorRef, anchor: CastleAnchor)? {
        guard let live = facts.liveKeyFileID, let file = facts.catalog.keyFile(id: live)?.document,
              let anchor = file.anchor else { return nil }
        return (AnchorRef(keyFile: live, kept: nil), anchor)
    }

    /// What opens this device's anchor itself (its own locks, and a
    /// follower's outgoing key by its copied locks or any other road to it).
    public func opensAnchor(_ ref: AnchorRef) -> OpensWith {
        let routes = (reach[.anchor(ref)] ?? [:]).map { Route(opener: $0.key, steps: $0.value) }
            .sorted { ($0.opener.rank, $0.steps.count) < ($1.opener.rank, $1.steps.count) }
        return OpensWith(routes: routes)
    }

    /// The sentence `door` says while this device's anchor exists; nil when
    /// there is no anchor.
    public func anchorSentence(for door: SecretReplacingDoor) -> AnchorSentence? {
        guard let (ref, anchor) = liveAnchor else { return nil }
        // The anchor's own roads — custody never opens an anchor, and the
        // Apple account never does by construction.
        var line = opensAnchor(ref).line.filter(\.isSecret)
        var replaced: Bool?
        switch door {
        case .replacesWords, .useCastleCannotFold:
            replaced = nil
        case .changePassphrase:
            replaced = line.contains(.passphrase(.current)) ? true : nil
        case .resetForgottenPassphrase:
            // It never points at the passphrase she said she forgot.
            line = line.filter { if case .passphrase = $0 { return false } else { return true } }
            replaced = nil
        }
        return AnchorSentence(door: door, day: anchor.madeAt, stillOpensWith: line, replacedSecretOpensIt: replaced)
    }
}
