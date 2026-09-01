//
//  NoteVersionsPaneTests.swift
//  VariorumTests
//
//  **THE POST-13L POLISH ROUND, BATCH 5** — ledger rows 16, 23, 24 and 30, plus
//  the architect's routed flags 2 and 3.
//
//  The round's headline: her floated shape, adopted — *"an easy door would be
//  to make a copy of the note, archive it, and then let you look through the
//  archived copies made at points in time."*
//
//  The door pins DRIVE THE REAL SURFACE (the 13l lesson; batch 3's technique
//  and batch 4's correction to it): the mounted `PostDetailView`, the real
//  `CommandRouter` seam, the real acts. **AppKit's accessibility tree is EMPTY
//  in this test host** — measured at batch 3 — so an AX-based presence pin would
//  pass vacuously; the evidence is the AppKit class names in the mounted
//  subtree, and the settle predicate waits for the LIST's rows rather than for
//  the column, because the column arrives a layout pass before what is inside
//  it (batch 4's own correction).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Note ▸ Versions (post-13l polish round, rows 16/23)", .serialized)
struct NoteVersionsPaneTests {
    // MARK: - The doors, declared and rendered (P-1)

    /// **TWO acts, and they are two on purpose:** saving a moment is an
    /// instant, keyable thing (⌘⇧S — V5's chord, the Mac's own save-as); the
    /// list of them is a panel. The pairing that TEACHES is ⌘S↔⌘⇧S — this
    /// take's moment beside this note's — which is her G4 chapter's lesson and
    /// the reason the chord had to be the shifted twin of commit's.
    @Test func theVersionsActsAreDeclaredOnBothBarsAndInThePalette() {
        let save = CapabilityRegistry.capability(.saveNoteVersion)
        #expect(save.scope == .post)
        #expect(save.verb == VersionsPath.saveVerb)
        #expect(save.shortcutLabel == "\u{2318}\u{21E7}S", "V5's chord, verified free")
        #expect(save.takesAccess == .native, "R118: not a Write privilege")
        #expect(!save.unavailableNote.isEmpty)

        let list = CapabilityRegistry.capability(.showNoteVersions)
        #expect(list.scope == .post)
        #expect(list.verb == VersionsPath.name)
        #expect(list.shortcutLabel == nil, "a listing is a panel, not a chord")

        // BOTH bars, in the same commit — R6-2's one-grammar rule.
        for bar in [CommitBar.renderedCapabilities, TakesBottomBar.renderedCapabilities] {
            #expect(bar.contains(.saveNoteVersion))
            #expect(bar.contains(.showNoteVersions))
            #expect(bar.contains(.commitTake), "the grain BELOW, in the same bar")
        }
        #expect(ShellActions.paletteActs.contains(.saveNoteVersion))
        #expect(ShellActions.paletteActs.contains(.showNoteVersions))
        // A routed command with no surface SPEAKS the declared note (P-2).
        #expect(!CapabilityRegistry.unhandledNote(
            for: .saveNoteVersion, context: CapabilityContext()).isEmpty)
        #expect(!CapabilityRegistry.unhandledNote(
            for: .showNoteVersions, context: CapabilityContext()).isEmpty)
        // Grey with no note; alive wherever a note is open.
        #expect(!CapabilityRegistry.isEnabled(
            .saveNoteVersion, in: CapabilityContext(mode: nil)))
        #expect(CapabilityRegistry.availability(
            .saveNoteVersion, in: CapabilityContext(mode: .write)) == .act)
    }

    /// **⌘⇧S IS THE ONLY `s` CHORD BESIDE ⌘S** — the collision sweep as a pin,
    /// so a future act cannot quietly take the chord that teaches the pairing.
    ///
    /// **The Act 10 correction round, batch A (a JUSTIFIED PIN EDIT):** a THIRD
    /// `s` chord exists now — ⌃⌘S, the platform's own Toggle Sidebar, declared
    /// when the shell's split became ours (row 2). It is named here by id so
    /// the pin still forbids any OTHER act from taking an `s` chord; the two
    /// moments' pairing (⌘S · ⌘⇧S) is untouched.
    @Test func theSaveAVersionChordIsTheShiftedTwinOfCommitAndNothingElseTakesIt() {
        var sChords: [(CapabilityID, String)] = []
        for id in CapabilityID.allCases {
            guard let label = CapabilityRegistry.capability(id).shortcutLabel,
                  label.uppercased().hasSuffix("S")
            else { continue }
            sChords.append((id, label))
        }
        let byID = Dictionary(uniqueKeysWithValues: sChords)
        #expect(byID[.commitTake] == "\u{2318}S")
        #expect(byID[.saveNoteVersion] == "\u{2318}\u{21E7}S")
        #expect(byID[.toggleSidebar] == "\u{2303}\u{2318}S", "the platform's sidebar chord")
        #expect(sChords.count == 3,
                "the two moments and the sidebar toggle carry the `s` chords: \(sChords.map(\.0))")
    }

    // MARK: - WALK-DRIVEN: the real mounted detail opens the real panel

    /// The detail registers a Versions seam with the router on appear, so the
    /// bars' door reaches ONE panel by composition — never a broadcast (P-4),
    /// and never the handler stack, whose LIFO order would hand the request to
    /// the editor's own sheet instead (batch 3's finding, unchanged).
    @Test func theMountedDetailOpensTheVersionsPaneInItsRealSidePanel() async throws {
        try await mounted { session, post, window, hosting in
            #expect(session.commandRouter.activePostID == post, "the detail registered")
            let atRest = TrayPanelMoveTests.classNames(hosting)
            #expect(!atRest.contains { $0.contains("InspectorStyleContext") },
                    "the side panel is not on screen at rest")
            #expect(atRest.contains("EditorTextView"), "the page itself IS mounted")

            #expect(session.commandRouter.requestNoteVersions(postID: post),
                    "the seam is registered — the request ACTED (P-2)")
            await Self.settle(window, hosting) {
                TrayPanelMoveTests.classNames(hosting).contains { $0.contains("OutlineList") }
            }
            let open = TrayPanelMoveTests.classNames(hosting)
            #expect(open.contains { $0.contains("InspectorStyleContext") },
                    "the inspector column really opened — her \"pane to the right\"")
            #expect(open.contains { $0.contains("OutlineList") },
                    "with the listing inside it")
            #expect(open.contains("EditorTextView"),
                    "beside the page, never instead of it (it is a panel, not a sheet)")
        }
    }

    /// A request for a post that is NOT mounted is refused rather than lost —
    /// and it never parks, for the history pane's reason: the doors that raise
    /// it are rendered by surfaces already mounted, so there is no focus
    /// change to wait out and the caller's own sheet takes it.
    @Test func aVersionsRequestForAnUnmountedPostIsRefusedSoTheBarCanFallBack()
        async throws
    {
        try await mounted { session, post, _, _ in
            #expect(!session.commandRouter.requestNoteVersions(postID: "some-other-note"),
                    "a stale target never opens a panel on the wrong note")
            #expect(session.commandRouter.requestNoteVersions(postID: post))
        }
    }

    // MARK: - The listing, driven through the real model

    /// **THE FOUR VERBS ON A REAL MOMENT**, through the pane's own model and
    /// the shipping acts: save · restore · promote · delete. It is one test on
    /// purpose — the family is the point, and each verb's meaning is only
    /// legible beside the others.
    @Test func theListingSavesRestoresPromotesAndDeletesARealMoment() async throws {
        try await mounted { session, post, _, _ in
            let model = NoteVersionsModel(session: session, postID: post)

            await model.save()
            #expect(model.status == .receipt(VersionsPath.saved))
            var listed = try await session.database.read {
                try Queries.noteVersions($0, of: post)
            }
            model.adopt(listed)
            #expect(model.versions.count == 1)
            let moment = try #require(model.versions.first)
            #expect(VersionsPath.rowMeta(moment).contains("1 block"))
            #expect(!VersionsPath.rowMeta(moment).contains("saved for you"),
                    "a hand-saved moment says nothing; 13w's rows are the ones that do")

            // Read: the moment's own text, one shot, capped honestly.
            #expect(await model.text(of: moment) == "A block, so the page has one.")

            // Restore: the note becomes it, and the moment of NOW joins the list.
            await model.restore(moment)
            #expect(model.status == .receipt(VersionsPath.restored))
            listed = try await session.database.read {
                try Queries.noteVersions($0, of: post)
            }
            #expect(listed.count == 2, "restoring saves where it was first")

            // Promote: it leaves the listing for the Library, forever.
            await model.promote(moment)
            #expect(model.status == .receipt(VersionsPath.promoted))
            listed = try await session.database.read {
                try Queries.noteVersions($0, of: post)
            }
            #expect(!listed.map(\.postID).contains(moment.postID))
            #expect(try await session.database.read { try Queries.library($0) }
                .map(\.postID).contains(moment.postID))

            // Delete: the remaining moment takes the ordinary Trash road.
            let remaining = try #require(listed.first)
            await model.delete(remaining)
            #expect(model.status == .receipt(VersionsPath.deleted))
            let now = session.now
            #expect(try await session.database.read { try Queries.trash($0, now: now) }
                .contains { $0.id == remaining.postID && $0.isVersion })
        }
    }

    /// **A REFUSAL IS NOT A RECEIPT, HERE TOO** (row 6's class, carried into
    /// the new surface rather than re-learned by it).
    @Test func thePaneTellsAReceiptFromARefusal() async throws {
        try await mounted { session, post, _, _ in
            let model = NoteVersionsModel(session: session, postID: post)
            await model.save()
            #expect(model.status?.isRefusal == false)
            let saved = try #require(try await session.database.read {
                try Queries.noteVersions($0, of: post)
            }.first)
            // A sealed note refuses the restore — content replacement IS
            // authoring, and the seal freezes authoring.
            try await session.runner.run { [post] ops in try ops.lockPost(post) }
            await model.restore(saved)
            #expect(model.status?.isRefusal == true)
            #expect(model.status?.text.contains("marked complete") == true)
        }
    }

    /// **AN EMPTY LISTING SAYS WHAT THE CHORD IS FOR**, rather than showing a
    /// blank panel — the door's own teaching, where she will meet it.
    @Test func anEmptyListingNamesTheChordThatFillsIt() {
        #expect(VersionsPath.empty.contains("\u{2318}\u{21E7}S"))
        #expect(VersionsPath.explainer.contains("restoring"))
        #expect(VersionsPath.restoreConfirmDetail.contains("saved as a new version first"),
                "the save-first promise is readable BEFORE the press, not only after")
    }

    // MARK: - V2: the confirm's one honest line

    /// **THE NOTE-DELETE CONFIRM GAINS ONE LINE, AND NOT A DIALOG** (V2,
    /// ratified: *"I agree it should auto delete versions and not ask for a
    /// confirmation dialog"*). Zero versions ⇒ the sentence is exactly what it
    /// was, which is what keeps every ordinary deletion unchanged.
    @Test func theDeleteConfirmSaysWhenVersionsGoWithItAndIsSilentOtherwise()
        async throws
    {
        try await mounted { session, post, _, _ in
            let plain = await NoteDeletion.ask(session: session, postIDs: [post])
            #expect(plain.versionCount == 0)
            #expect(plain.detail == RecoveryCopy.deleteNotesConfirmDetail(1),
                    "a note with no moments reads exactly as it always did")

            try await session.runner.run { [post] ops in
                try ops.saveNoteVersion(post)
                try ops.saveNoteVersion(post)
            }
            let withVersions = await NoteDeletion.ask(session: session, postIDs: [post])
            #expect(withVersions.versionCount == 2)
            #expect(withVersions.detail.contains("2 saved versions go with it"))
            #expect(withVersions.detail.contains(RecoveryCopy.trashSection),
                    "…beside the road, which is still the one it always named")
        }
    }

    // MARK: - FOUND-ITEM 1: the Trash's version rows

    /// **A DELETED MOMENT GATHERS UNDER ITS NOTE AND SAYS WHAT IT IS.** A
    /// version is a container, so it rides the `.note` arm and every `.note`
    /// door unchanged — what the FACE owes is the context, and the honest way
    /// to say it for several rows is the header her G7 grouping already built.
    @Test func deletedVersionsGroupUnderTheirNoteRatherThanReadingAsNotes()
        async throws
    {
        try await mounted { session, post, _, _ in
            try await session.runner.run { [post] ops in
                try ops.saveNoteVersion(post)
                try ops.saveNoteVersion(post)
            }
            let versions = try await session.database.read {
                try Queries.noteVersionIDs($0, of: post)
            }
            for id in versions {
                try await session.runner.run { ops in try ops.deleteContainer(id) }
            }
            let now = session.now
            let rows = try await session.database.read { try Queries.trash($0, now: now) }
            #expect(rows.filter(\.isVersion).count == 2)
            #expect(rows.allSatisfy { $0.versionOfNoteID == nil || $0.versionOfNoteID == post })

            // The grouping: two moments of one live note, under one header.
            let entries = TrashGrouping.entries(rows)
            #expect(entries.count == 1, "one group, not two loose note rows")
            guard case .group(let group) = entries[0] else {
                Issue.record("the versions did not gather"); return
            }
            #expect(group.noteID == post)
            #expect(group.noteRow == nil, "the note itself is alive — only its moments went")
            #expect(group.rows.count == 2)
        }
    }

    /// …and the note itself HEADS the group when it goes too (V2's ride, seen
    /// from the Trash: *"the Trash's note-group shows the note with its
    /// versions"*).
    @Test func deletingTheNoteShowsItHeadingItsOwnMoments() async throws {
        try await mounted { session, post, _, _ in
            try await session.runner.run { [post] ops in
                try ops.saveNoteVersion(post)
                try ops.deleteContainer(post)
            }
            let now = session.now
            let rows = try await session.database.read { try Queries.trash($0, now: now) }
            let entries = TrashGrouping.entries(rows)
            #expect(entries.count == 1)
            guard case .group(let group) = entries[0] else {
                Issue.record("the note and its moment did not gather"); return
            }
            #expect(group.noteRow?.id == post, "the note's own row is the header")
            #expect(group.rows.map(\.item.isVersion) == [true])
        }
    }

    // MARK: - Row 30: the ancestors fold

    /// **HER MID-ROUND REFINEMENT, AS A VALUE.** *"I think the ancestors should
    /// be collapsible with a dropdown arrow style toggle or something like
    /// that optionally (not collapsed by default)."* The label carries the
    /// COUNT either way, because a fold that hides its own size is not an
    /// audit — the tray's takes disclosure, same rule.
    @Test func theStrandedAncestorsFoldCarriesItsCountAndSaysWhatTheyAre() {
        #expect(RecoveryPath.strandedAncestorsDisclosure(1).contains("1 original"))
        #expect(RecoveryPath.strandedAncestorsDisclosure(30).contains("30 originals"),
                "her own 30-ancestor scenario, readable at a glance")
        #expect(!RecoveryPath.strandedAncestorsDisclosure(3).lowercased()
            .contains("unplaced"), "G3: the debug noun never reaches her eyes")
    }

    // MARK: - Routed flag 2: the boards stop reading receipts as alarms

    /// **A RECEIPT IS NOT A REFUSAL, ON THE BOARDS TOO** (ledger row 6's
    /// defect, one surface over — batch 4 recorded it and deliberately did not
    /// paint the slot alarm wholesale, because that would have made every
    /// receipt read as an error: the defect, not the fix).
    ///
    /// The class is decided WHERE THE MESSAGE IS PRODUCED, and the two doors
    /// are `setStatus` (something happened) and `speak` (fire-and-speak — the
    /// door that cannot act in its context and says why). `statusMessage`
    /// survives as a forwarder, so every shipped pin rides unmodified.
    @Test func theBoardTellsAReceiptFromARefusal() async throws {
        try await mounted { session, post, _, _ in
            let takes = TakesViewModel(session: session, postID: post)
            takes.setStatus("New block added at the end — type away.")
            #expect(takes.status?.isRefusal == false, "a door that DID something")
            #expect(takes.statusMessage == "New block added at the end — type away.",
                    "the forwarder still answers — the 3C parity pattern")

            takes.speak("Click into a block first — divide cuts the block you're in.")
            #expect(takes.status?.isRefusal == true,
                    "fire-and-speak exists for the door that cannot act (P-2)")

            takes.setRefusal(TakesViewModel.message(for: OperationError.lockedPost(id: post)))
            #expect(takes.status?.isRefusal == true)

            takes.setStatus(nil)
            #expect(takes.status == nil && takes.statusMessage == nil)
        }
    }

    // MARK: - Routed flag 3: the bridge row's last literal red

    /// **THE BRIDGE ROW TAKES A VOICE.** It is in `Shared/`, so neither of
    /// batch 4's two roads reaches it: the Mac's `.alarmVoice()` is Mac-only
    /// (the mobile target would not compile a call to it), and
    /// `\.sharedPageStyle` is **nil on macOS by construction** — a pinned
    /// one-seam law, which would have made a `pageCaptionError` "fix" compile
    /// to the same literal red. A defaulted parameter is the road that works
    /// for both, and the ONE caller passes the live voice.
    @Test func theBridgeRowTakesTheLiveVoiceAndTheMacPassesIt() throws {
        let source = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("Shared/BridgeStatusViews.swift"),
            encoding: .utf8)
        #expect(source.contains("var tokens: VoiceTokens?"))
        #expect(source.contains("tokens?.alarm ?? .red"),
                "the alarm token where the literal was")
        let root = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .appendingPathComponent("Variorum/RootView.swift"),
            encoding: .utf8)
        #expect(root.contains("tokens: theme.tokens(for: scheme)"),
                "the one caller really hands it over — otherwise the seam is a no-op")
    }

    // MARK: - Harness

    private func mounted(
        _ body: @escaping (AppSession, String, NSWindow, NSView) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the note")
            _ = try session.operations.newBlock(
                in: post.id, text: "A block, so the page has one.")
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: "postMode.\(post.id)")
            }
            let hosting = NSHostingView(
                rootView: PostDetailView(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await Self.settle(window, hosting) {
                session.commandRouter.activePostID == post.id
            }
            try await body(session, post.id, window, hosting)
        }
    }

    private nonisolated static func pump(_ seconds: TimeInterval = 0.03) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(
        _ window: NSWindow, _ hosting: NSView,
        maxTurns: Int = 60, until predicate: () -> Bool
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            Self.pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }
}
