//
//  RestoredCopyJoinWordsMomentTests.swift
//  VariorumCoreTests — VX-529 unit 3, the rider VX-523 (the VX-510 walk's W-6): A JOIN FROM A RESTORED COPY WHOSE WORDS
//  ALREADY ARE THE ACCOUNT'S. On a synced Mac, Make this my library lands the copy as a NEW library "under your current
//  pair" (rule 17) — the account's pair, since the device was synced (rule 7) — and binds no account (P-VX378-U2-4 (a),
//  whose own text says "a later join is rule 7's — and since it already holds the current pair, which is the account's
//  when the device was synced, no words are replaced"). Joining it by the account's PASSPHRASE owed the words moment
//  (`ActNotice.wordsReplacedByAccount`): the one quiet rule (`ProtectionExecutor.wordsAreTheAccountsAlready`,
//  VX-456/VX-462) proves sameness by wrap identity — no own words lock, the master's twelve-words copy byte-equal to the
//  vault's recovery wrap, a master lock the account's master opens — and Make this my library's new key file was built
//  with an OWN words lock and no master lock or copy (`makeMineKeyFile` → `newLocks(words: true, master: false)`), so the
//  rule's first clause failed and nothing else could prove the words from the files alone. A join by the WORDS stays quiet
//  (they open the own lock — the rule's other arm).
//
//  VX-529 L2 — THE FIX, HER R-529-7 ("(A) in this run"): when the session is signed in and the account's vault is readable,
//  Make this my library ALSO writes the join's two proof fields into the new library's key file — the master lock and the
//  master's twelve-words copy — exactly as a join writes them (no own words lock beside the copy: VX-462), PROVEN by the
//  current pair's typed WORDS opening that vault's master through its recovery wrap (P-VX529-L2-1). Where the read is
//  unavailable or the words don't open the vault, it writes NOTHING: the file is today's, byte for byte, and a later join
//  speaks — truthfully. The fields ride the act's EXISTING planned key-file write: no new step, no new write. The held row
//  below is the pin (red on the pre-fix tree, held there as a known issue); the edges each have theirs.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A restored copy on a synced Mac — the shared setup (the account on `mac`; `laptop` JOINED it by the passphrase, the
/// VX-462 shape: no own words lock, the master and its words copy; the laptop's own backup of that library planted as a
/// copy). `before` runs between the copy's planting and the press (a change elsewhere, the server going away).
struct RestoredCopyWorld {
    let mac: EX
    let laptop: EX
    let executor: ProtectionExecutor
    var library: UnlockedLibrary
    let copy: CatalogCopy
    let catalog: Catalog
    /// The outgoing library's identity and key file, as the press found them.
    let oldID: String
    let outgoingFile: KeyFile

    var account: String { mac.account! }
    /// The current pair typed at the press — the account's pair as this laptop holds it.
    var currentPair: TypedSecrets { TypedSecrets(passphrase: mac.passphrase, words: mac.words) }
    /// What opens the copy at its door: nothing under Standard (this Mac's silent item holds its key); the passphrase under
    /// Castle Always ask (no item at all — rule 9).
    var copySecrets: TypedSecrets {
        laptop.mode == .castle && laptop.gate == .alwaysAsk ? TypedSecrets(passphrase: mac.passphrase) : .none
    }

    static func make(_ mode: ProtectionMode = .standard, gate: GateStyle? = nil) async throws -> RestoredCopyWorld {
        let mac = try EX(mode, synced: true, gate: gate)
        let laptop = try EX(mode, gate: gate, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        // The fixture's own session from here (the crash harness's relaunch executors are signed in as the account too).
        laptop.account = mac.account
        let synced = try #require(laptop.world.liveFormat3)
        #expect(synced.words == nil && synced.masterWordsCopy != nil, "the joined laptop holds the account's pair")
        let (copy, catalog) = try plantCopy(
            laptop, libraryID: laptop.libraryID, key: library.key, keyFile: synced, record: laptop.liveRecord)
        laptop.world.writes = []
        return RestoredCopyWorld(
            mac: mac, laptop: laptop, executor: executor, library: library, copy: copy, catalog: catalog,
            oldID: try #require(library.record?.libraryID), outgoingFile: synced)
    }

    /// The press — the secrets form, its door's read of the vault its own (`.inTheDoor`, the default).
    mutating func makeMine() async throws -> ActOutcome {
        try await executor.makeThisMyLibrary(
            &library, copy: copy, in: catalog, copySecrets: copySecrets, currentPair: currentPair)
    }

    /// The vault as the server holds it now.
    var vault: AccountVault { mac.world.server.snapshot(account)!.vault }

    /// The account's master, by the passphrase the vault holds now (`passphrase`: the one it was last re-made with).
    func accountsMaster(passphrase: String? = nil) throws -> SymmetricKey {
        let text = passphrase ?? mac.passphrase
        return try #require(vault.master(passphrase: try PassphraseKey.derive(text, kdf: vault.kdf), words: nil))
    }

    /// Another device re-made the account's twelve words (a key door there re-wraps only the vault's master).
    func wordsChangedElsewhere() throws -> [String] {
        let held = try #require(mac.world.server.accounts[account])
        let fresh = try RecoveryPhrase.generate()
        mac.world.server.accounts[account] = ExecutorVault.Account(
            revision: held.revision + 1,
            vault: try VaultModel.rewrappingWords(
                held.vault, master: try accountsMaster(), words: try WordsKey.derive(fresh), device: "Studio Mac"),
            updatedAt: nil)
        return fresh
    }

    /// Another device re-made the account's passphrase (a fresh descriptor, as every new passphrase takes).
    func passphraseChangedElsewhere(_ text: String) throws {
        let held = try #require(mac.world.server.accounts[account])
        mac.world.server.accounts[account] = ExecutorVault.Account(
            revision: held.revision + 1,
            vault: try VaultModel.rewrappingPassphrase(
                held.vault, master: try accountsMaster(), passphrase: try PF.passphraseKey(text), device: "Studio Mac"),
            updatedAt: nil)
    }

    /// The new library's key file carries the join's two proof fields, exactly as a join writes them: no own words lock,
    /// the master lock under the account's master, the master's twelve-words copy the vault's recovery wrap byte for byte.
    func carriesTheProof(_ file: KeyFile?, master: SymmetricKey) -> Bool {
        guard let file else { return false }
        return file.words == nil && file.masterWordsCopy == vault.masterByWords && (try? file.open(master: master)) != nil
    }

    /// TODAY'S file for the new library, byte for byte: a fresh key with no past under the current passphrase (the outgoing
    /// lock's descriptor), its OWN words lock, and — Standard — the fresh own Apple key it names; no master, no copy.
    func todaysFile(_ live: KeyFile, key: StoreKey) throws -> KeyFile {
        let wrap = try #require(outgoingFile.passphrase)
        var locks = NewKeyLocks(
            passphrase: try PassphraseKey.derive(mac.passphrase, kdf: wrap.kdf), words: try WordsKey.derive(mac.words))
        if let apple = live.apple { locks.apple = try #require(laptop.world.icloud.keys[apple.keyID]) }
        return try KeyFile.building(libraryID: live.libraryID, key: key, epoch: 1, locks: locks)
    }
}

@Suite("VX-529 unit 3 — VX-523: a join from a restored copy whose words are the account's")
struct RestoredCopyJoinWordsMomentTests {
    private func replaced(_ outcome: ActOutcome) -> Bool { outcome.notices.contains(.wordsReplacedByAccount) }

    /// The account (another device turned sync on first), a laptop that JOINED it by the passphrase (the VX-462 shape: no
    /// own words lock, the master and its words copy), and the laptop's own backup made its library by Make this my
    /// library under the CURRENT pair — the account's.
    private func aRestoredCopyOnASyncedMac() async throws -> (mac: EX, laptop: EX, executor: ProtectionExecutor,
                                                              library: UnlockedLibrary) {
        let mac = try EX(.standard, synced: true)
        let laptop = try EX(.standard, world: ExecutorWorld(icloud: mac.world.icloud, server: mac.world.server))
        let executor = laptop.executor(session: mac.session)
        var library = try laptop.unlocked(executor)
        _ = try await executor.enroll(&library, typed: TypedSecrets(passphrase: mac.passphrase))
        let synced = try #require(laptop.world.liveFormat3)
        #expect(synced.words == nil && synced.masterWordsCopy != nil, "the joined laptop holds the account's pair")
        let (copy, catalog) = try plantCopy(
            laptop, libraryID: laptop.libraryID, key: library.key, keyFile: synced, record: laptop.liveRecord)
        _ = try await executor.makeThisMyLibrary(
            &library, copy: copy, in: catalog, currentPair: TypedSecrets(passphrase: mac.passphrase, words: mac.words))
        #expect(library.record?.account == nil, "the new library binds no account (P-VX378-U2-4 (a))")
        let restored = try #require(laptop.world.liveFormat3)
        // VX-529 L2 (F-L2-1) — FLIPPED DELIBERATELY: this line read `restored.open(words:)` (the OWN words lock). The fix
        // writes the join's shape — no own words lock beside the master's copy — so the words open it through the copy;
        // the any-road open keeps the line's intent ("it holds the account's words") on both sides of the fix.
        #expect(try restored.open(.words(mac.words), floor: PF.floor) == library.key, "it holds the account's words")
        return (mac, laptop, executor, library)
    }

    /// **W-6 — the walk's road; THE PIN (red on the pre-fix tree, held there as a known issue; VX-529 L2 flipped it — the
    /// `withKnownIssue` removed):** the restored copy joins by the account's PASSPHRASE. Its words already are the
    /// account's — nothing is replaced, so the moment is owed nothing.
    @Test func aRestoredCopyJoiningByThePassphraseHearsNoReplacement() async throws {
        let restored = try await aRestoredCopyOnASyncedMac()
        var library = restored.library
        let joined = try await restored.executor.enroll(&library, typed: TypedSecrets(passphrase: restored.mac.passphrase))
        #expect(restored.laptop.liveRecord?.account == restored.mac.account)
        #expect(!replaced(joined), "the restored copy's words were the account's already — nothing to say")
    }

    /// The other arm, a guard (green on both sides): by the WORDS, they open the restored copy — quiet.
    @Test func aRestoredCopyJoiningByTheWordsIsQuiet() async throws {
        let restored = try await aRestoredCopyOnASyncedMac()
        var library = restored.library
        let joined = try await restored.executor.enroll(&library, typed: TypedSecrets(words: restored.mac.words))
        #expect(!replaced(joined))
    }
}

/// VX-529 L2 — R-529-7's edges, each pinned: the shape the fix writes (every posture), the offline press and the pair
/// changed elsewhere (nothing written — today's file — and the moment speaks, truthfully), the passphrase alone changed
/// elsewhere (P-VX529-L2-1: the words prove it — written, quiet), no new write, and a crash after every write.
@Suite("VX-529 L2 — VX-523 (R-529-7): Make this my library writes the join's two proof fields when provable, nothing otherwise")
struct RestoredCopyProofFieldsTests {
    private func replaced(_ outcome: ActOutcome) -> Bool { outcome.notices.contains(.wordsReplacedByAccount) }

    /// RED ON OLD — THE SHAPE, all three postures: signed in, the vault readable, the current pair's words the account's —
    /// the new library's key file carries the master lock and the vault's recovery wrap and NO own words lock (the join's
    /// shape); the current pair opens it (rule 17); it binds no account, has no past, holds no new opener but the master
    /// lock (Castle: no Apple lock — rule 9); nothing was written to the vault, the sync keys or custody beyond today's;
    /// and the join that follows by the passphrase is QUIET.
    @Test func signedInAndReadableTheNewKeyFileCarriesTheJoinsTwoFields() async throws {
        for (mode, gate) in [(ProtectionMode.standard, GateStyle?.none), (.castle, .touchID), (.castle, .alwaysAsk)] {
            var world = try await RestoredCopyWorld.make(mode, gate: gate)
            let context = "\(mode) \(gate.map { "\($0)" } ?? "")"
            _ = try await world.makeMine()
            let record = try #require(world.laptop.liveRecord)
            #expect(record.libraryID != world.oldID && record.account == nil && record.mode == mode, "\(context)")
            let live = try #require(world.laptop.world.liveFormat3)
            #expect(world.carriesTheProof(live, master: try world.accountsMaster()), "\(context): the join's two fields")
            #expect(live.history.isEmpty && live.fingerprint == PF.fp(world.library.key), "\(context): no past")
            #expect(try live.open(passphrase: .passphrase(world.mac.passphrase), floor: PF.floor) == world.library.key,
                    "\(context): the current passphrase opens it")
            #expect(try live.open(.words(world.mac.words), floor: PF.floor) == world.library.key,
                    "\(context): the current words open it (through the master's copy)")
            #expect((mode == .castle) == (live.apple == nil), "\(context): the Apple lock as today")
            #expect(!world.laptop.world.writes.contains {
                switch $0 {
                case .vaultCreate, .vaultUpdate, .syncKeys, .syncKeysDelete: return true
                default: return false
                }
            }, "\(context): no vault or sync-keys write — \(world.laptop.world.writes)")
            expectSettled(world.laptop, world.library, context)
            let joined = try await world.executor.enroll(&world.library, typed: TypedSecrets(passphrase: world.mac.passphrase))
            #expect(!replaced(joined), "\(context): the words were the account's — the moment stays quiet")
        }
    }

    /// GUARD (green on both sides by nature — the fix must not write here): OFFLINE at the press, the door's read can't
    /// reach the vault — NOTHING is written beyond today's file, byte for byte (an own words lock, no master, no copy), and
    /// the join that follows once online SPEAKS (truthfully — every sentence true; P-VX309-U2-1's honest-limit class).
    @Test func offlineThePressWritesTodaysFileAndTheMomentSpeaks() async throws {
        for (mode, gate) in [(ProtectionMode.standard, GateStyle?.none), (.castle, .alwaysAsk)] {
            var world = try await RestoredCopyWorld.make(mode, gate: gate)
            world.mac.world.server.reachable = false
            _ = try await world.makeMine()
            let live = try #require(world.laptop.world.liveFormat3)
            #expect(live == (try world.todaysFile(live, key: world.library.key)), "\(mode): today's file, byte for byte")
            #expect(live.master == nil && live.masterWordsCopy == nil && live.words != nil, "\(mode)")
            world.mac.world.server.reachable = true
            let joined = try await world.executor.enroll(&world.library, typed: TypedSecrets(passphrase: world.mac.passphrase))
            #expect(replaced(joined), "\(mode): unprovable at the press — the moment speaks")
        }
    }

    /// GUARD (green on both sides by nature): the account's WORDS were re-made on another device since this Mac last knew
    /// them — the current pair's words no longer open the vault, so nothing proves the pair: today's file, byte for byte;
    /// the later join speaks, and TRUTHFULLY (the account's words did replace the library's).
    @Test func theWordsChangedElsewhereNothingIsWrittenAndTheMomentSpeaks() async throws {
        for (mode, gate) in [(ProtectionMode.standard, GateStyle?.none), (.castle, .alwaysAsk)] {
            var world = try await RestoredCopyWorld.make(mode, gate: gate)
            let newWords = try world.wordsChangedElsewhere()
            _ = try await world.makeMine()
            let live = try #require(world.laptop.world.liveFormat3)
            #expect(live == (try world.todaysFile(live, key: world.library.key)), "\(mode): today's file, byte for byte")
            let joined = try await world.executor.enroll(&world.library, typed: TypedSecrets(passphrase: world.mac.passphrase))
            #expect(replaced(joined), "\(mode): the account's words replaced the library's — said")
            #expect(try world.laptop.world.liveFormat3?.open(.words(newWords), floor: PF.floor) == world.library.key)
        }
    }

    /// RED ON OLD — P-VX529-L2-1 (a): the account's PASSPHRASE alone was re-made elsewhere (the words unchanged) — the
    /// words still open the vault, so the pair's words are PROVEN the account's: the fields are written (the current
    /// passphrase — the one this Mac knew — keeps its lock, rule 17), and the join that follows by the account's NEW
    /// passphrase stays quiet: truthfully, no words were replaced.
    @Test func thePassphraseAloneChangedElsewhereTheWordsStillProveIt() async throws {
        let newPassphrase = "a passphrase made on the Studio Mac"
        for (mode, gate) in [(ProtectionMode.standard, GateStyle?.none), (.castle, .alwaysAsk)] {
            var world = try await RestoredCopyWorld.make(mode, gate: gate)
            try world.passphraseChangedElsewhere(newPassphrase)
            _ = try await world.makeMine()
            let live = try #require(world.laptop.world.liveFormat3)
            #expect(world.carriesTheProof(live, master: try world.accountsMaster(passphrase: newPassphrase)), "\(mode)")
            #expect(try live.open(passphrase: .passphrase(world.mac.passphrase), floor: PF.floor) == world.library.key,
                    "\(mode): the current passphrase (this Mac's) still opens it")
            let joined = try await world.executor.enroll(&world.library, typed: TypedSecrets(passphrase: newPassphrase))
            #expect(!replaced(joined), "\(mode): no words were replaced — quiet")
        }
    }

    /// GUARD (green on both sides by nature) — NO NEW WRITE, NO NEW STEP: the press that carries the proof writes exactly
    /// the writes, in exactly the order, of the press that can't (offline) — the fields ride the act's one key-file write.
    @Test func theProofAddsNoWrite() async throws {
        for (mode, gate) in [(ProtectionMode.standard, GateStyle?.none), (.castle, .touchID), (.castle, .alwaysAsk)] {
            var proven = try await RestoredCopyWorld.make(mode, gate: gate)
            _ = try await proven.makeMine()
            var offline = try await RestoredCopyWorld.make(mode, gate: gate)
            offline.mac.world.server.reachable = false
            _ = try await offline.makeMine()
            #expect(Self.kinds(proven.laptop.world.writes) == Self.kinds(offline.laptop.world.writes),
                    "\(mode): \(proven.laptop.world.writes) vs \(offline.laptop.world.writes)")
        }
    }

    /// RED ON OLD — RULE 20 with the fields: a crash after every write of the press, then the relaunch's settle — the act
    /// finished (the new library, its key file carrying the two fields) or never happened (the outgoing library, its key
    /// file as it was), never a third state; before the stage a resume holds no copy key and rolls back (P-U3-6), so the
    /// proof is never needed past the press. (Standard and Castle Touch ID: this harness's lobby tries the custody items
    /// and the LIVE key file only, so under Always ask a crash between the new key file and the swap leaves the outgoing
    /// library reachable only through this Mac's mirror — which the app's lobby tries, `heldKeyFiles`, and this harness
    /// doesn't; that road is today's, the fields change nothing in it.)
    @Test func aCrashAfterEveryWriteFinishesWithTheFieldsOrNeverHappened() async throws {
        for (mode, gate) in [(ProtectionMode.standard, GateStyle?.none), (.castle, .touchID)] {
            var world: RestoredCopyWorld!
            try await CrashHarness.everywhere(
                {
                    world = try await RestoredCopyWorld.make(mode, gate: gate)
                    return world.laptop
                },
                act: { fixture, executor, library in
                    // The session's read, as every open's pane makes (decision 35's fresh read for a Standard library).
                    _ = try await executor.readVault(accountID: world.account)
                    _ = try await executor.makeThisMyLibrary(
                        &library, copy: world.copy, in: world.catalog, copySecrets: world.copySecrets,
                        currentPair: world.currentPair)
                },
                finished: { fixture, _ in
                    guard fixture.liveRecord.map({ $0.libraryID != world.oldID }) == true,
                          Set(fixture.world.memories.keys).count == 1, let master = try? world.accountsMaster()
                    else { return false }
                    return world.carriesTheProof(fixture.world.liveFormat3, master: master)
                },
                neverHappened: { fixture, _ in
                    fixture.liveRecord?.libraryID == world.oldID && Set(fixture.world.memories.keys) == [world.oldID]
                        && fixture.world.liveFormat3 == world.outgoingFile
                },
                typed: { _ in world.currentPair },
                resumeMayRollBack: true)
        }
    }

    /// A write's kind, its fingerprints and ids dropped (the two runs mint their own keys).
    static func kinds(_ writes: [WorldWrite]) -> [String] {
        writes.map { write in
            switch write {
            case .custody(_, let c): return "custody+ \(c.rawValue)"
            case .custodyDelete(_, let c): return "custody- \(c.rawValue)"
            case .syncKeys(let c): return "sync+ \(c.rawValue)"
            case .syncKeysDelete(let c): return "sync- \(c.rawValue)"
            case .appleAdd: return "apple+"
            case .appleDelete: return "apple-"
            case .vaultCreate: return "vault create"
            case .vaultUpdate(let what): return "vault \(what)"
            case .record: return "record"
            case .stage: return "stage"
            case .stagedRecord: return "staged-record"
            case .swap: return "swap"
            case .discardStaged: return "discard-staged"
            case .keyFile: return "keyfile"
            case .memory: return "memory"
            case .memoryDelete: return "memory-"
            case .plan: return "plan"
            case .planDelete: return "plan-"
            case .backup: return "backup"
            case .sendPair: return "send"
            case .copiesDelete: return "copies-"
            case .plaintextExport: return "export"
            }
        }
    }
}

/// VX-529 L2 — the scenario world's own pass: on a synced Mac, Make this my library of its own backup carries the join's
/// two fields; every promise holds after it, after the re-join, and after a later Use Castle on the unbound restored copy
/// (rule 11's entry takes in the account's silent sync-keys item the library doesn't name — census class (L)).
@Suite("VX-529 L2 — VX-523: the restored copy's proof fields through the scenario world")
struct RestoredCopyProofFieldsScenarios {
    /// RED ON OLD (the fields): Standard and Castle, the re-join after.
    @Test func aSyncedMacsRestoredCopyCarriesTheProofAndKeepsEveryPromise() async throws {
        for mode in ProtectionMode.allCases {
            let (world, account) = try await syncedWorld(mode, devices: ["macA"])
            await world.done([.launch("macA"), .backup("macA"), .makeMine("macA", pick: 0, typing: .itsDay), .settle])
            #expect(world.macA.slot?.record?.account == nil, "\(mode): the restored copy binds no account")
            let live = world.liveKeyFile(world.macA)
            let vault = try #require(world.server.snapshot(account)?.vault)
            #expect(live?.words == nil && live?.master != nil && live?.masterWordsCopy == vault.masterByWords,
                    "\(mode): the join's two fields, the vault's recovery wrap byte for byte")
            expectPromisesKept(world, "\(mode) after Make this my library")
            await world.done([.turnOnSync("macA"), .settle])
            #expect(world.macA.slot?.record?.account == account, "\(mode): re-joined")
            expectPromisesKept(world, "\(mode) after the re-join")
        }
    }

    /// RED ON OLD (the fields): Standard — the restored copy, unbound, then Use Castle on this Mac: every promise holds.
    @Test func theRestoredCopyThenUseCastleKeepsEveryPromise() async throws {
        let (world, _) = try await syncedWorld(.standard, devices: ["macA"])
        await world.done([.launch("macA"), .backup("macA"), .makeMine("macA", pick: 0, typing: .itsDay), .settle])
        #expect(world.liveKeyFile(world.macA)?.master != nil, "the restored copy carries the master lock")
        expectPromisesKept(world, "after Make this my library")
        await world.done([.useCastle("macA", .alwaysAsk, newWords: false), .settle])
        #expect(world.macA.slot?.record?.mode == .castle)
        expectPromisesKept(world, "after Use Castle")
    }
}
