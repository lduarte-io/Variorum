import Foundation
import Testing

@testable import VariorumCore

// Phase 13x U1 row 5 (VX-64) — THE DRILL FIXTURE MINTER. Not a test of
// anything: an env-gated tool that mints the encrypted THROWAWAY store
// the vault-bootstrap headless drill runs against, kept in the suite so
// the drill is re-runnable by any session (reviewer, orchestrator) with
// one command and zero bespoke scripts:
//
//   VX64_FIXTURE_DIR=/path swift test --filter Vx64DrillFixtureTests
//
// It writes: <dir>/variorum.sqlite (encrypted, one marker row),
// <dir>/variorum-keys-<fp>.json (a PRODUCTION-KDF passphrase wrap — the
// tool's unwrap floor-checks the descriptor, so a fast test KDF would be
// refused), and <dir>/pass.txt (the drill passphrase, trailing newline).
// Skipped (condition false) in every ordinary run; never touches
// anything outside the given directory.

@Suite("13x U1 — the VX-64 drill's fixture minter (env-gated)")
struct Vx64DrillFixtureTests {
    static var fixtureDirectory: String? {
        ProcessInfo.processInfo.environment["VX64_FIXTURE_DIR"]
    }

    static let drillPassphrase = "vx64 drill passphrase"

    @Test(.enabled(if: fixtureDirectory != nil))
    func mintTheDrillFixture() throws {
        let dir = URL(fileURLWithPath: try #require(Self.fixtureDirectory), isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let store = dir.appendingPathComponent("variorum.sqlite")
        #expect(!FileManager.default.fileExists(atPath: store.path),
                "the fixture dir must be fresh — refuse to overwrite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        try database.write { db in
            try db.execute(
                sql: """
                    INSERT INTO container (id, kind, title, created_at, updated_at)
                    VALUES ('vx64-drill-marker', 'post', 'the drill row', '2027-01-01T00:00:00Z', '2027-01-01T00:00:00Z')
                    """)
        }
        _ = database.asRebindable().binding.lock()
        var envelope = StoreKeyEnvelope()
        // The PRODUCTION descriptor — the tool's floor check must pass.
        try envelope.setPassphraseWrap(key: key, passphrase: Self.drillPassphrase)
        try envelope.write(at: envelope.preferredURL(besideStore: store))
        try Data((Self.drillPassphrase + "\n").utf8)
            .write(to: dir.appendingPathComponent("pass.txt"))
        #expect(StoreFilePresence.classify(at: store) == .encryptedOrUnknown)
    }
}
