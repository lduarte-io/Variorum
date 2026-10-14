import CryptoKit
import Foundation

/// **THE SETUP-KEY RULE — who a connection IS** (VX-168; the VX-156 brief §12's
/// K2, her kickoff ruling R-VX168-1 — the run record
/// `notes/plans/fixes/vx-168-mcp-client-secret.md`).
///
/// A client names itself in `initialize` (A-4 — the name IS the identity a
/// grant gates). Since VX-168 every setup copied from Settings ▸ MCP carries a
/// fresh KEY, which the `variorum-mcp` shim speaks as a one-line preamble
/// before the first frame; this rule decides, ONCE PER CONNECTION, whether the
/// key the connection presented ties it to the name it claims. It decides
/// identity only — whether the name is approved, pending or denied stays
/// `MCPGrantRule`'s, per call, exactly as before.
///
/// The arms (each pinned by a state-transition test, `MCPSetupKeyTests`):
/// - **No key (a bare shim, or any process that never ran a setup) → refuse**,
///   under ANY name, bound or not — her word: no grandfathering.
/// - **A name bound to a key:** its own key → admit. **A FRESH key — minted
///   by a Copy setup command and never yet presented — RE-BINDS the name**
///   (VX-198, her R-VX184-5: "the newest copied setup wins" — re-running a
///   client's setup is all it takes; approval and grants are untouched, since
///   this rule decides identity only) — **since VX-258, when the key was
///   copied FOR that name, or the name carries no approval; otherwise it
///   WAITS for her OK** (below). The key it replaced then refuses with its own
///   reason (`replaced`); a key bound to ANOTHER name, or one this library
///   never minted, refuses as the impostor's (two tools under one name told
///   apart: the one holding the newest setup is the name's).
/// - **A name with no key bound** (approved before VX-168, released by Deny or
///   an adoption, or a fresh name): a key minted by a copy and not yet
///   presented CLAIMS it — an UNKNOWN name becomes a connection request bound
///   to the key (K2: "the first name that presents it binds to it", effective
///   at her approval); a KNOWN unbound name binds it at once (R-VX168-1: "just
///   re-run the setup" — no revoke, no re-approval ceremony) — since VX-258
///   the same condition as above: an approved name binds at once only a key
///   copied for it. A key already bound to another name, or one this library
///   never minted (or no longer holds), refuses.
///
/// Every refusal answers the CLIENT with ONE sentence (no oracle telling a
/// wrong key from a missing binding) — save `replaced`, whose own sentence
/// only the replaced key's holder can hear (VX-198); `Refusal` exists for her
/// Activity list, which speaks precisely.
///
/// **VX-258 — keys tied to their tab; an Any-client re-bind waits for her OK**
/// (VX-184's ladder round 1's MAJOR; her ruling: "tie keys to their tab and
/// for the general "Any MCP client" case, we should probably do the re-bind
/// waits for my ok? i don't want everyone who isn't using claude or codex to
/// be vulnerable to this. the best protection at each level"; the run record
/// `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U1). A key copied
/// from ONE client's setup carries that client's NAME inside its text
/// (`copiedFor`) — authenticated by the hash, which covers the whole key, so
/// an edited tag is a key this library never minted. The tag only ever ADDS:
/// a key copied for a name takes that name with ZERO clicks (the re-run
/// setup — R-VX184-5 and R-VX168-1 as she ruled them); any other fresh key
/// (an "Any MCP client" copy, a key minted before VX-258, another client's
/// copy) may take a name that carries her APPROVAL only by her OK — it waits
/// (`awaitRebind`), admitted with NO reach. A name with no approval to
/// inherit (pending, denied, unknown) keeps the arms it had: nothing there
/// for a stranger to take, and her approval still decides.
///
/// Recorded non-defeat (K2's own): the key lives in the client's settings,
/// readable by any program running as her — it tells tools apart and turns
/// away a stray bare launch, never same-user malware.
public enum MCPSetupKeyRule {
    // MARK: - The key's form

    /// The UNTAGGED key's version prefix — `vmk1_` + 43 base64url characters
    /// (256 random bits), shell- and JSON-safe as written. Since VX-258 it is
    /// an "Any MCP client" copy's form (and every key minted before VX-258).
    public static let prefix = "vmk1_"

    /// VX-258: a key copied for ONE client's setup — `vmk2_<name>_` + 43
    /// base64url characters, the name the client calls itself in its
    /// `initialize`. The random part is fixed-length, so the name is read
    /// from the right and may itself hold `_`.
    public static let copiedForPrefix = "vmk2_"

    /// The random part's length (32 bytes, unpadded base64url).
    static let randomLength = 43

    /// The longest name a key may carry (the setup menu's names are short;
    /// the preamble's 256-character cap holds with room to spare).
    public static let copiedForNameLimit = 64

    /// VX-258: a name a key may carry — 1…64 characters of `A–Z a–z 0–9 . _ -`
    /// (shell-, TOML- and JSON-safe as written, so every setup the pane copies
    /// stays pasteable).
    public static func canCarry(_ name: String) -> Bool {
        !name.isEmpty && name.utf8.count <= copiedForNameLimit
            && name.utf8.allSatisfy { byte in
                (byte >= 0x30 && byte <= 0x39) || (byte >= 0x41 && byte <= 0x5A) || (byte >= 0x61 && byte <= 0x7A)
                    || byte == UInt8(ascii: ".") || byte == UInt8(ascii: "_") || byte == UInt8(ascii: "-")
            }
    }

    /// The key minted from 32 random bytes (the caller supplies the bytes —
    /// CryptoKit's generator in production — so this stays pure). VX-258:
    /// `copiedFor` — the client name its setup was copied for (nil = an "Any
    /// MCP client" copy, the untagged form); a name it cannot carry
    /// (`canCarry`) is the caller's error — the mint refuses before this.
    public static func key(fromRandomBytes bytes: Data, copiedFor name: String? = nil) -> String {
        let random = bytes.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        guard let name else { return prefix + random }
        return copiedForPrefix + name + "_" + random
    }

    /// VX-258: the client name a PRESENTED key was copied for, read from its
    /// text — nil for an untagged key (an "Any MCP client" copy, or one minted
    /// before VX-258) and for anything not shaped like a tagged key. Trust it
    /// only for a key this library minted (the hash covers the tag): `decide`
    /// reads it only in the `.unclaimed` arm.
    public static func copiedFor(_ key: String) -> String? {
        guard key.hasPrefix(copiedForPrefix) else { return nil }
        let body = key.dropFirst(copiedForPrefix.count)
        guard body.count > randomLength + 1 else { return nil }
        let separator = body.index(body.endIndex, offsetBy: -(randomLength + 1))
        guard body[separator] == "_" else { return nil }
        let name = String(body[body.startIndex..<separator])
        return canCarry(name) ? name : nil
    }

    /// The stored form: hex SHA-256 over a domain-separated encoding of the
    /// key exactly as presented. The library never holds a key, only this;
    /// a 256-bit random key needs no salt or slow hash (nothing to guess).
    public static func hash(_ key: String) -> String {
        let digest = SHA256.hash(data: Data(("variorum.mcp-setup-key.v1:" + key).utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - The facts

    /// The client row the connection's name finds, as the rule needs it.
    public struct Client: Equatable, Sendable {
        public var id: String
        /// The hash of the key bound to the name; nil = unbound.
        public var boundHash: String?
        /// VX-258: whether the name carries her APPROVAL (and so whatever she
        /// has shared with it) — what a key not copied for it may take only by
        /// her OK. Defaults to TRUE, the fail-safe reading: a caller that does
        /// not say treats the name as one worth protecting.
        public var approved: Bool

        public init(id: String, boundHash: String?, approved: Bool = true) {
            self.id = id
            self.boundHash = boundHash
            self.approved = approved
        }
    }

    /// Where the PRESENTED key stands in this library.
    public enum KeyStanding: Equatable, Sendable {
        /// Minted by a copy and not yet presented by any name.
        case unclaimed
        /// Bound to the client with this id.
        case boundTo(clientID: String)
        /// VX-198: this NAME was bound to it until a newer setup re-bound the
        /// name — remembered by the rebind's own Activity row (P-VX198-1).
        case replaced
        /// VX-258: claimed by a connection under this client's name and
        /// waiting for her OK to bind it (`mcp_rebind_request`).
        case awaiting(clientID: String)
        /// Never minted here, or no longer held (pushed past the cap, or
        /// released by Deny or an adoption — or replaced longer ago than the
        /// Activity log remembers).
        case unknown
    }

    // MARK: - The decision

    public enum Decision: Equatable, Sendable {
        /// The name's own key.
        case admit
        /// A KNOWN name with no key bound claims this unclaimed key
        /// (R-VX168-1).
        case bind
        /// VX-198 (R-VX184-5): a BOUND name presents a fresh, unclaimed key —
        /// the newest copied setup — and takes it in place of the old one.
        case rebind
        /// An UNKNOWN name claims this unclaimed key: a new connection
        /// request, bound to it (K2).
        case request
        /// VX-258: a fresh key NOT copied for this name, under a name that
        /// carries her approval — the key is claimed for the name and WAITS
        /// for her OK; the connection is admitted with NO reach (it answers
        /// exactly as a connection request does) until she allows it.
        case awaitRebind
        case refuse(Refusal)

        /// The connection is served at all (an `awaitRebind` one with no
        /// reach — the session holds it to the request's face).
        public var admits: Bool {
            if case .refuse = self { return false }
            return true
        }
    }

    /// Why a connection was refused — for her Activity list only; the
    /// client hears one sentence for all of them.
    public enum Refusal: String, CaseIterable, Sendable {
        /// `initialize` named no client.
        case unnamed
        /// No key was presented (a bare shim).
        case bare
        /// A key this library never minted, or no longer holds.
        case notIssued
        /// The key is bound to a different name.
        case anotherNamesKey
        /// The name is bound to a different key (the impostor).
        case notThisNamesKey
        /// VX-198: the key a newer setup replaced under this name — the
        /// client hears its OWN sentence (`MCPHandshake.replacedRefusal`):
        /// only the old key's holder can trigger it, and it tells that holder
        /// only its own key's history, so it opens no oracle.
        case replaced
    }

    /// **The one decision**, per connection.
    /// - `name`: the name `initialize` declared, trimmed.
    /// - `client`: the row that name finds (nil = a name never seen).
    /// - `presentedHash`: `hash(key)` of the presented key; nil = bare.
    /// - `copiedFor`: VX-258 — the name the presented key was copied for
    ///   (`copiedFor(_:)`; nil = untagged — the fail-safe default, no
    ///   zero-click right anywhere). Read only in the `.unclaimed` arm, where
    ///   the hash proves this library minted that very text.
    /// - `standing`: where that key stands (ignored when bare).
    public static func decide(
        name: String, client: Client?, presentedHash: String?, copiedFor: String? = nil, standing: KeyStanding
    ) -> Decision {
        guard !name.isEmpty else { return .refuse(.unnamed) }
        guard let presentedHash else { return .refuse(.bare) }
        if let bound = client?.boundHash, bound == presentedHash { return .admit }
        let bound = client?.boundHash != nil
        switch standing {
        case .unclaimed:
            guard let client else { return .request }    // K2: first contact is her approval's
            // VX-258: a key copied for THIS name takes it with zero clicks (the
            // re-run setup); any other may take a name carrying her approval
            // only by her OK.
            if client.approved, copiedFor != name { return .awaitRebind }
            return bound ? .rebind : .bind               // VX-198 · R-VX168-1
        case .awaiting(let clientID):
            // The key waits under one name: that name re-presenting it still
            // waits; under any other it is another name's key.
            return client?.id == clientID ? .awaitRebind : .refuse(.anotherNamesKey)
        case .replaced: return .refuse(.replaced)
        case .boundTo: return .refuse(bound ? .notThisNamesKey : .anotherNamesKey)
        case .unknown: return .refuse(bound ? .notThisNamesKey : .notIssued)
        }
    }

    // MARK: - The activity log's acts (her Activity list's words key on these)

    /// The act a refused connection logs.
    public static func activityAct(_ refusal: Refusal) -> String {
        switch refusal {
        case .unnamed: "connect_unnamed"
        case .bare: "connect_bare"
        case .notIssued: "connect_not_issued"
        case .anotherNamesKey: "connect_another_names_key"
        case .notThisNamesKey: "connect_not_this_names_key"
        case .replaced: "connect_replaced_key"
        }
    }

    /// The act an existing name's FIRST key logs when it binds (allowed).
    public static let boundAct = "connect_bound"

    /// VX-198: the act a REBIND logs (allowed). Its row is also the replaced
    /// key's memory: `target_kind` = `replacedTargetKind`, `target_id` = the
    /// REPLACED key's hash (a dead key's hash, never shown — the row carries
    /// no title). PROVISIONAL P-VX198-1 (the memory's home).
    public static let reboundAct = "connect_rebound"
    /// The rebind row's target kind.
    public static let replacedTargetKind = "setup_key"

    /// VX-258: the act a key's FIRST presentation logs when it waits for her
    /// OK (logged as refused — it reaches nothing until she allows). A waiting
    /// key presented again logs nothing.
    public static let awaitingAct = "connect_rebind_waiting"
    /// VX-258: her Allow — the waiting key took the name. Its row carries the
    /// key it REPLACED as its target (nil when the name was unbound), so that
    /// key still hears its own sentence (`replaced` — VX-198's memory).
    public static let rebindAllowedAct = "connect_rebind_allowed"
    /// VX-258: her Don't allow — the waiting key is forgotten.
    public static let rebindDeclinedAct = "connect_rebind_declined"
    /// The acts whose rows remember a REPLACED key (`.replaced`'s memory).
    public static let replacingActs = [reboundAct, rebindAllowedAct]
}
