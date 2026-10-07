import Foundation

// Phase 13x, U2 row 6 — THE RESTORE SURFACE's LISTING BRAIN (the QB
// ruling's second framed door: *Restore from Backup…* on Data Safety,
// "listing the app's own snapshot pairs, saying which credential opens
// which" — decision 11's pair model rendered). Pure reads, no crypto, no
// secrets: a folder listing, the backup-name parser's own strictness
// (`StoreBackup.date(fromBackupURL:)` restated — the stamp must round-trip
// and the tail be empty or `-` + eight lowercase hex), the serving key
// file resolved THROUGH the U1 classifier (one pair brain, never a
// second), and the key file's wraps read keylessly into credential facts.
//
// THE SAME-FINGERPRINT SECOND LOOK (pre-13x ledger 14's U4→13x half): a
// candidate under the LIVE library's own key is served by the live
// custody too — Touch ID and the current passphrase open it on the Mac
// the library lives on, without any folder being touched. The flag is
// computed here (the envelope's full fingerprint against the live one,
// falling back to the name's fp8 against the live short form); the face
// words it.

public enum BackupRestoreCandidates {
    /// Which of decision 11's roads this snapshot's key file carries.
    public struct Credentials: Equatable, Sendable {
        /// The passphrase of its day (the pair is written with its
        /// snapshot and never rewritten).
        public var passphrase: Bool
        /// The twelve words — always, unless regenerated since.
        public var recovery: Bool
        /// The Apple-account copy (a Standard-era snapshot).
        public var apple: Bool
        /// The master-wrapped copy — an enrolled device's master, or the
        /// CURRENT passphrase online through the account.
        public var master: Bool

        public init(passphrase: Bool, recovery: Bool, apple: Bool, master: Bool) {
            self.passphrase = passphrase
            self.recovery = recovery
            self.apple = apple
            self.master = master
        }
    }

    public struct Candidate: Equatable, Sendable {
        public var snapshot: URL
        /// The stamp the name carries (every listed candidate parses).
        public var date: Date
        /// The name's fp8; nil = a legacy stamp-only name.
        public var fingerprint8: String?
        /// The serving key file (the classifier's three roads); nil = no
        /// key file serves it — the honest bare class, listed so the face
        /// can SAY it rather than hide the copy.
        public var keyFile: URL?
        /// The wraps the serving key file carries; nil when none serves
        /// it or the file would not read.
        public var credentials: Credentials?
        /// The second look: this snapshot is under the LIVE library's own
        /// key, so the live custody (Touch ID / the current passphrase)
        /// opens it here.
        public var opensWithLiveCustody: Bool
    }

    /// The folder's candidates, NEWEST FIRST. `liveKeyFingerprint` is the
    /// open library's full key fingerprint (`AppDatabase
    /// .storeKeyFingerprint`); nil = no live key in hand (locked, or a
    /// plaintext-era store) — the second look simply never lights.
    public static func gather(in folder: URL, liveKeyFingerprint: String?) -> [Candidate] {
        let entries = (try? FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: nil)) ?? []
        return entries
            .compactMap { entry -> Candidate? in
                guard entry.pathExtension == "sqlite",
                      let date = backupDate(entry) else { return nil }
                // The caller's path form, as everywhere in the family.
                let snapshot = folder.appendingPathComponent(
                    entry.lastPathComponent, isDirectory: false)
                return candidate(
                    for: snapshot, date: date, liveKeyFingerprint: liveKeyFingerprint)
            }
            .sorted {
                ($0.date, $0.snapshot.lastPathComponent)
                    > ($1.date, $1.snapshot.lastPathComponent)
            }
    }

    private static func candidate(
        for snapshot: URL, date: Date, liveKeyFingerprint: String?
    ) -> Candidate {
        let (_, fp8) = LibraryClassifier.backupNameFingerprint(snapshot)
        var keyFile: URL?
        switch LibraryClassifier.classify(at: snapshot) {
        case .snapshotPair(_, let served), .encryptedLibrary(_, let served):
            keyFile = served
        default:
            keyFile = nil
        }
        var credentials: Credentials?
        var envelopeFingerprint: String?
        if let keyFile, let envelope = try? StoreKeyEnvelope.load(at: keyFile) {
            credentials = Credentials(
                passphrase: envelope.passphrase != nil,
                recovery: envelope.recovery != nil,
                apple: envelope.apple != nil,
                master: envelope.master != nil)
            envelopeFingerprint = envelope.keyFingerprint
        }
        let secondLook: Bool
        if let live = liveKeyFingerprint {
            if let envelopeFingerprint {
                secondLook = envelopeFingerprint == live
            } else if let fp8 {
                secondLook = StoreKeyEnvelope.shortFingerprint(live) == fp8
            } else {
                secondLook = false
            }
        } else {
            secondLook = false
        }
        return Candidate(
            snapshot: snapshot, date: date, fingerprint8: fp8,
            keyFile: keyFile, credentials: credentials,
            opensWithLiveCustody: secondLook)
    }

    /// The app's own backup names and ONLY those — `variorum-backup-
    /// <stamp>` or `variorum-backup-<stamp>-<fp8>`, the stamp reading back
    /// exactly as the writer formats it (`StoreBackup.date(fromBackupURL:)`
    /// restated; a foreign name that merely starts with a stamp is not the
    /// app's).
    public static func backupDate(_ url: URL) -> Date? {
        let name = url.deletingPathExtension().lastPathComponent
        guard name.hasPrefix("variorum-backup-") else { return nil }
        let rest = name.dropFirst("variorum-backup-".count)
        guard rest.count >= stampLength else { return nil }
        let stamp = String(rest.prefix(stampLength))
        let tail = rest.dropFirst(stampLength)
        let fingerprintTail = tail.count == 9 && tail.first == "-"
            && tail.dropFirst().allSatisfy { "0123456789abcdef".contains($0) }
        guard tail.isEmpty || fingerprintTail else { return nil }
        guard let date = stampFormatter.date(from: stamp),
              stampFormatter.string(from: date) == stamp else { return nil }
        return date
    }

    /// `yyyy-MM-dd-HHmmss` is 17 characters.
    private static let stampLength = 17

    nonisolated(unsafe) private static let stampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()
}
