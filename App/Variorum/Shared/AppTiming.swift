//
//  AppTiming.swift
//  Variorum (Shared)
//
//  VM-65 (the VM-64 run, batch 1) — THE APP'S TIMING CATALOG AND ITS ONE
//  RECORDER. The brain is `VariorumCore/Diagnostics/TimingRecorder` (headless,
//  tested); this file names what the app measures, and every mark's meaning
//  lives HERE — a call site is one line that says what just happened, never a
//  re-derivation of which spans it ends. The record is
//  `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 1; §7 its closeout).
//
//  ## Why the catalog is shared code
//
//  Some moments happen in shared code — owner adoption and the sync round
//  (`AppServices`, `SyncSession`), the savepoint on leaving (`AppSession`), the
//  autosave write (`AutosaveCoordinator`), the store opening (`AppBootstrap`).
//  The Mac compiles every one of those marks, so **the recorder is DISABLED
//  until the phone enables it at launch** (`MobileTiming.start`): on the Mac
//  each mark is one atomic load and a return, and nothing is recorded,
//  persisted or signposted. The Mac's behaviour is unchanged by construction.
//
//  ## What is measured (her named moments, then the counts later batches need)
//
//  Her words: "There's significant lag when going to the quick entry box, when
//  going from the quick entry box into a note." Her ruling's moments: tap on
//  the capture box, keyboard up, file, note on screen, unlock, library ready.
//  Audit F's flows F1–F6 (`notes/plans/vm-44/audit/F-performance-trace.md`
//  §11) choose the spans; the run's batches 3–7 choose the counts.
//
//  **Durations and counts only.** Nothing here takes or keeps note text, a
//  title or an id — the brain's API has no string parameter at all.
//

import Foundation
import MachO
import os
import VariorumCore

// MARK: - The catalog

/// A series: a span's durations (ms) or a per-act count. The raw values are the
/// persisted names — renaming one starts that series afresh (an unknown name is
/// dropped on restore), so they never change for wording; the words a person
/// reads are the phone readout's (`MobileTimingCopy`).
nonisolated enum AppTimingSeries: String, TimingSeriesKey {
    // ── The capture box (lag 1, and lag 2's first half) ──
    /// The box takes the caret → the keyboard is fully up (F1).
    case boxTapToKeyboard
    /// One completed filing of the box — Open's, or a leaving's (F3 B1–B6).
    case boxFile
    /// Open pressed (⏎ or the open door) → the note's text on screen (lag 2, F3).
    case boxOpenToNote
    /// Open pressed → the keyboard up in the note (F3 "→ keyboard live").
    case boxOpenToKeyboard

    // ── Notes ──
    /// Any road: the note screen requested → its text on screen (F6; the
    /// hand-off's navigation half when the road is the box).
    case noteOpenToScreen
    /// A note left (popped) → its teardown and leaving savepoint done (F1 1D).
    case noteLeave

    // ── Launch and unlock (F4, F5) ──
    /// The process started → the lock screen showing (a cold launch under Castle).
    case launchToLockScreen
    /// The process started → the library open (no lock screen in between).
    case launchToLibraryOpen
    /// The process started → the home screen on screen.
    case launchToHome
    /// The process started → the Library's first listing delivered.
    case launchToLibraryReady
    /// Face ID or the passphrase accepted → the library open.
    case unlockToLibraryOpen
    /// Unlock accepted → the home screen on screen.
    case unlockToHome
    /// Unlock accepted → the Library's first listing delivered.
    case unlockToLibraryReady

    // ── The store and sync (batch 4; the minute-long empty round she saw) ──
    /// Owner adoption at the services' start (duration).
    case ownerAdoption
    /// Rows it stamped (a count).
    case ownerAdoptionRows
    /// One sync round, start to finish (duration).
    case syncRound
    /// Rows the round's push took off the outbox (about — it is the outbox's
    /// drop, so rows queued during the round are subtracted from it: a burst of
    /// writes mid-round under-reads it, down to 0).
    case syncRoundSent
    /// Server changes the round's pull moved past (about — the cursor's
    /// advance, which counts this device's own pushed rows too).
    case syncRoundReceived

    // ── Per-act counts (counting windows — batches 5, 6, 7) ──
    /// Whole-note projection reads from a note's arrival to its first live
    /// delivery (audit F 2C: two today).
    case noteReadsPerOpen
    /// Whole-note projection re-reads in the second after a save (every
    /// mounted editor re-reads on any write — audit F §7).
    case noteRereadsPerSave
    /// Library listing re-runs in the second after a save (audit F 1E).
    case libraryRereadsPerSave
    /// Library listing deliveries (redraws) in the second after a save.
    case libraryRedrawsPerSave
    /// Savepoint attempts inside one leaving — a note's pop, or the app's
    /// backgrounding with everything it sets off (audit F 6C: up to three;
    /// VM-71: one per note that owes one — `savepointAttempt` below).
    case savepointsPerLeaving

    var signpostName: StaticString {
        switch self {
        case .boxTapToKeyboard: return "Box tap to keyboard"
        case .boxFile: return "Box file"
        case .boxOpenToNote: return "Box open to note"
        case .boxOpenToKeyboard: return "Box open to keyboard"
        case .noteOpenToScreen: return "Note open to screen"
        case .noteLeave: return "Note leave"
        case .launchToLockScreen: return "Launch to lock screen"
        case .launchToLibraryOpen: return "Launch to library open"
        case .launchToHome: return "Launch to home"
        case .launchToLibraryReady: return "Launch to Library ready"
        case .unlockToLibraryOpen: return "Unlock to library open"
        case .unlockToHome: return "Unlock to home"
        case .unlockToLibraryReady: return "Unlock to Library ready"
        case .ownerAdoption: return "Owner adoption"
        case .ownerAdoptionRows: return "Owner adoption rows"
        case .syncRound: return "Sync round"
        case .syncRoundSent: return "Sync round sent"
        case .syncRoundReceived: return "Sync round received"
        case .noteReadsPerOpen: return "Note reads per open"
        case .noteRereadsPerSave: return "Note re-reads per save"
        case .libraryRereadsPerSave: return "Library re-reads per save"
        case .libraryRedrawsPerSave: return "Library redraws per save"
        case .savepointsPerLeaving: return "Savepoints per leaving"
        }
    }
}

/// Monotonic totals — the denominators and the raw events the windows count.
nonisolated enum AppTimingCounter: String, TimingCounterKey {
    /// A note screen arrived (its `.task` ran — once per realized screen).
    case noteArrival
    /// An editor view model was built. Builds ÷ arrivals above one is audit F
    /// 2D's twin graph, confirmed.
    case editorBuilt
    /// The arrival's authoritative load read the whole note (`loadOnce`).
    case noteProjectionLoad
    /// The note's live observation ran its whole-note fetch (its first, and
    /// every re-run on a write anywhere).
    case noteProjectionFetch
    /// …and delivered a changed projection to the editor.
    case noteProjectionDelivery
    /// A tab switch re-read the whole note (`refreshTakesFromStore`).
    case noteProjectionRefresh
    /// The Library's note listing ran its fetch / delivered.
    case libraryFetch
    case libraryDelivery
    /// The Library's bookless listing ran its fetch / delivered.
    case booklessFetch
    case booklessDelivery
    /// One autosave write landed (a take's buffer).
    case autosaveWrite
    /// One leaving savepoint the store's runner was asked to write. Until
    /// VM-71 every `savepointOnLeaving` call was one; since VM-71 the phone
    /// asks the runner only for a note its read found owing one (a take that
    /// differs from its last savepoint), so a repeated ask in one leaving that
    /// finds nothing owed is not an attempt. The same quantity before and
    /// after: runner turns for a leaving savepoint.
    case savepointAttempt
    /// A note was left (popped) / the app was left (backgrounded).
    case noteLeaving
    case appLeaving
}

// MARK: - The one recorder and every mark

nonisolated enum AppTiming {
    typealias Token = TimingToken<AppTimingSeries>

    /// The process's one recorder. Disabled until the phone's launch enables
    /// it; the Mac never does.
    static let recorder = TimingRecorder<AppTimingSeries, AppTimingCounter>(
        signposter: OSSignposter(subsystem: "io.lduarte.Variorum", category: "timing"))

    static var isEnabled: Bool { recorder.isEnabled }

    /// How long a waiting moment may stay open before its end is dropped
    /// rather than paired: a screen-level wait.
    static let screenStale: Duration = .seconds(30)
    /// …and a launch or an unlock, which waits on a cold store.
    static let launchStale: Duration = .seconds(120)
    /// A per-act count's window: an open counts until its first live delivery
    /// (or this); a leaving counts what it sets off (or this).
    static let actWindow: Duration = .seconds(10)
    /// A save's window: the wake-ups in the second after it (or until the next
    /// save — each save gets its own).
    static let saveWindow: Duration = .seconds(1)

    // MARK: The capture box

    /// The box took the caret. A box that takes it with the keyboard already
    /// up waits for nothing, so only a fresh keyboard begins the span.
    static func boxFocused(keyboardAlreadyUp: Bool) {
        guard !keyboardAlreadyUp else { return }
        recorder.begin(.boxTapToKeyboard, staleAfter: screenStale)
    }

    /// Open pressed (⏎ or the open door).
    static func boxOpenPressed() {
        recorder.begin(.boxOpenToNote, staleAfter: screenStale)
        recorder.begin(.boxOpenToKeyboard, staleAfter: screenStale)
    }

    /// A filing begins — recorded only when it completes (`boxFilingEnded`).
    static func boxFilingStarted() -> Token? { recorder.start(.boxFile) }

    /// A filing ended: `filed` false (an empty box, a refusal, a withdrawal)
    /// records nothing.
    static func boxFilingEnded(_ token: Token?, filed: Bool) {
        if filed { recorder.finish(token) } else { recorder.discard(token) }
    }

    /// The keyboard finished rising (`keyboardDidShow`).
    static func keyboardUp() {
        recorder.endIfOpen(.boxTapToKeyboard)
        recorder.endIfOpen(.boxOpenToKeyboard)
    }

    // MARK: Notes

    /// The note screen was requested (its destination built). A rebuild of the
    /// same screen restarts the span — a few milliseconds short, never a stale
    /// begin paired with a later open.
    static func noteRequested() {
        recorder.begin(.noteOpenToScreen, staleAfter: screenStale)
    }

    /// An editor view model was built.
    static func editorBuilt() { recorder.count(.editorBuilt) }

    /// The note screen arrived: the reads of THIS open are counted until its
    /// live observation first delivers (`noteFirstDelivery`).
    static func noteArrived() {
        recorder.count(.noteArrival)
        recorder.openWindow(
            .noteReadsPerOpen, counting: [.noteProjectionLoad, .noteProjectionFetch],
            for: actWindow, policy: .keepFirst)
    }

    /// The note's text is on screen (the frame after its first render).
    static func notePainted() {
        recorder.endIfOpen(.noteOpenToScreen)
        recorder.endIfOpen(.boxOpenToNote)
    }

    static func noteProjectionLoaded() { recorder.count(.noteProjectionLoad) }
    /// Called from the observation's fetch (GRDB's queue — the brain is
    /// thread-safe).
    static func noteProjectionFetched() { recorder.count(.noteProjectionFetch) }
    static func noteProjectionDelivered(first: Bool) {
        recorder.count(.noteProjectionDelivery)
        if first { recorder.closeWindow(.noteReadsPerOpen) }
    }
    static func noteProjectionRefreshed() { recorder.count(.noteProjectionRefresh) }

    /// A note is being left: its savepoint attempts are counted, and the leave
    /// is timed until `noteLeft`.
    static func noteLeaving() -> Token? {
        recorder.count(.noteLeaving)
        openLeavingWindow()
        return recorder.start(.noteLeave)
    }

    static func noteLeft(_ token: Token?) { recorder.finish(token) }

    // MARK: Leaving the app, savepoints, saves

    /// The app was backgrounded.
    static func appLeaving() {
        recorder.count(.appLeaving)
        openLeavingWindow()
    }

    /// `AppSession.savepointOnLeaving` asked the runner for a leaving
    /// savepoint (on the phone, only when something was owed — VM-71).
    static func savepointAttempted() { recorder.count(.savepointAttempt) }

    /// An autosave write is about to land: the wake-ups it sets off are counted
    /// from HERE (a write's re-fetches can start before its caller resumes).
    static func autosaveWillWrite() {
        recorder.openWindow(
            .noteRereadsPerSave, counting: [.noteProjectionFetch], for: saveWindow, policy: .restart)
        recorder.openWindow(
            .libraryRereadsPerSave, counting: [.libraryFetch, .booklessFetch],
            for: saveWindow, policy: .restart)
        recorder.openWindow(
            .libraryRedrawsPerSave, counting: [.libraryDelivery, .booklessDelivery],
            for: saveWindow, policy: .restart)
    }

    /// …it landed.
    static func autosaveWrote() { recorder.count(.autosaveWrite) }

    /// …it was refused: nothing it set off is a save's.
    static func autosaveRefused() {
        recorder.cancelWindow(.noteRereadsPerSave)
        recorder.cancelWindow(.libraryRereadsPerSave)
        recorder.cancelWindow(.libraryRedrawsPerSave)
    }

    private static func openLeavingWindow() {
        recorder.openWindow(
            .savepointsPerLeaving, counting: [.savepointAttempt], for: actWindow, policy: .keepFirst)
    }

    // MARK: The Library

    /// A Library listing ran its fetch (GRDB's queue).
    static func libraryFetched(bookless: Bool) {
        recorder.count(bookless ? .booklessFetch : .libraryFetch)
    }

    /// A Library listing delivered. The note listing's FIRST delivery after a
    /// launch or an unlock is "the library ready".
    static func libraryDelivered(bookless: Bool, first: Bool) {
        recorder.count(bookless ? .booklessDelivery : .libraryDelivery)
        if first, !bookless {
            recorder.endIfOpen(.launchToLibraryReady)
            recorder.endIfOpen(.unlockToLibraryReady)
        }
    }

    // MARK: Launch and unlock

    /// The process launched; `processStart` is its true start on this
    /// recorder's clock (nil: measure from now).
    static func launched(processStart: TimingInstant?) {
        for series in [AppTimingSeries.launchToLockScreen, .launchToLibraryOpen, .launchToHome, .launchToLibraryReady] {
            recorder.begin(series, at: processStart, staleAfter: launchStale)
        }
    }

    /// The lock screen is showing. On a cold launch under Castle that ends the
    /// launch's own wait; what follows waits on her, so the launch's other
    /// spans end here unrecorded and the unlock's take over.
    static func lockScreenShown() {
        recorder.endIfOpen(.launchToLockScreen)
        recorder.cancel(.launchToLibraryOpen)
        recorder.cancel(.launchToHome)
        recorder.cancel(.launchToLibraryReady)
    }

    /// Face ID or the passphrase was accepted.
    static func unlockAccepted() {
        for series in [AppTimingSeries.unlockToLibraryOpen, .unlockToHome, .unlockToLibraryReady] {
            recorder.begin(series, staleAfter: launchStale)
        }
    }

    /// The store is open and the session built (`AppBootstrap.finish(.ready)`).
    static func libraryOpened() {
        recorder.endIfOpen(.launchToLibraryOpen)
        recorder.endIfOpen(.unlockToLibraryOpen)
        recorder.cancel(.launchToLockScreen)
    }

    /// The home screen is on screen (the frame after the shell appeared).
    static func homeOnScreen() {
        recorder.endIfOpen(.launchToHome)
        recorder.endIfOpen(.unlockToHome)
    }

    // MARK: Owner adoption and the sync round

    static func ownerAdoptionStarted() -> Token? { recorder.start(.ownerAdoption) }

    /// `rows`: how many rows it stamped (nil when it failed — the duration is
    /// still the wait it cost).
    static func ownerAdoptionEnded(_ token: Token?, rows: Int?) {
        recorder.finish(token)
        if let rows { recorder.record(.ownerAdoptionRows, value: Double(rows)) }
    }

    static func syncRoundStarted() -> Token? { recorder.start(.syncRound) }

    /// The round ended (clean or failed — either way it was a wait). `sent`:
    /// the outbox rows it took (nil when the start's reading had not landed) —
    /// the outbox at the start less what is still owed, so it can under-read
    /// under a mid-round burst; a burst bigger than the push would make it
    /// negative, and that clamps to 0 here.
    static func syncRoundEnded(_ token: Token?, sent: Int?) {
        recorder.finish(token)
        if let sent { recorder.record(.syncRoundSent, value: Double(max(0, sent))) }
    }

    /// The server changes the ended round's pull moved past (its own read,
    /// after the round).
    static func syncRoundReceived(_ changes: Int) {
        recorder.record(.syncRoundReceived, value: Double(max(0, changes)))
    }

    /// A round whose chain was replaced or stopped mid-round: not measured.
    static func syncRoundDropped(_ token: Token?) { recorder.discard(token) }

    // (Survival — one table per build, in a file in the app's own container,
    // saved in batches off every timed path — is the phone's:
    // `MobileTiming` + `MobileTimingStore`, over Core's `TimingBook`.)

    // MARK: - The process's own facts (no store, no ids of hers)

    /// The running binary's build fingerprint: the main executable's `LC_UUID`,
    /// which every link of new code changes. The phone's build number is not
    /// stamped (CFBundleVersion is 1 for every build — verified in the project
    /// file at this batch), so the number alone cannot tell two installs apart;
    /// this can. nil only if the header cannot be read.
    static func buildFingerprint() -> String? {
        guard let header = _dyld_get_image_header(0) else { return nil }
        let headerSize = header.pointee.magic == MH_MAGIC_64
            ? MemoryLayout<mach_header_64>.size : MemoryLayout<mach_header>.size
        var cursor = UnsafeRawPointer(header) + headerSize
        for _ in 0..<header.pointee.ncmds {
            let command = cursor.loadUnaligned(as: load_command.self)
            if command.cmd == UInt32(LC_UUID) {
                return UUID(uuid: cursor.loadUnaligned(as: uuid_command.self).uuid).uuidString
            }
            cursor += Int(command.cmdsize)
        }
        return nil
    }

    /// The process's true start, as a reading of the recorder's clock: the
    /// kernel's start time for this pid, carried back from now. It includes
    /// the time before the app's own code ran (dyld, static initializers), which
    /// is part of what a cold launch costs her. nil when the kernel does not
    /// answer, or the answer is not believable (negative, or over a minute).
    static func processStartInstant() -> TimingInstant? {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        guard sysctl(&mib, u_int(mib.count), &info, &size, nil, 0) == 0 else { return nil }
        let started = info.kp_proc.p_un.__p_starttime
        var now = timeval()
        gettimeofday(&now, nil)
        let elapsedMicros = Int64(now.tv_sec - started.tv_sec) * 1_000_000
            + Int64(now.tv_usec - started.tv_usec)
        guard elapsedMicros >= 0, elapsedMicros < 60_000_000 else { return nil }
        let nowInstant = TimingClock.now()
        let elapsed = UInt64(elapsedMicros) * 1_000
        return nowInstant > elapsed ? nowInstant - elapsed : nil
    }
}
