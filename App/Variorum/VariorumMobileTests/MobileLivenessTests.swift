//
//  MobileLivenessTests.swift
//  VariorumMobileTests
//
//  Mobile S3 ladder, round-1 fix pass — the liveness authority's pins:
//  the BLOCKER's text-loss round trip (one per-post coordinator + one
//  live editor anywhere), MAJOR 1's background-flush arms (the
//  registration set, never a single slot), MAJOR 2's arrival focus (the
//  window-hosted S2 pattern), and MINOR 2's two-editor voice flip.
//

import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// **THE SEAM THE INTERIOR-ARM PINS RIDE.** `AutosaveCoordinator` notifies
/// its settle observers SYNCHRONOUSLY at the tail of `flushNow`, so a
/// closure installed here runs while `takeLiveness` is still inside its
/// `await` — before the guard that follows it. That is a deterministic
/// stand-in for "a second tab tap landed mid-flight", and it is the only
/// honest one available: a real second tap would be a timing race, and a
/// pin about ordering must not itself depend on timing.
///
/// `at` counts settles within one grant: 1 is `takeLiveness`'s own flush,
/// 2 is the flush `refreshTakesFromStore` opens with.
@MainActor
private final class SupersedeOnSettle {
    private let at: Int
    private let editors: MobileLivenessAuthority
    private var seen = 0
    private(set) var fired = false

    init(at: Int, editors: MobileLivenessAuthority) {
        self.at = at
        self.editors = editors
    }

    func fire() {
        seen += 1
        guard seen == at, !fired else { return }
        fired = true
        editors.beginHandoff()
    }
}

/// Two editors on one post, one per tab — the alive-stacks shape every
/// liveness pin needs. The library editor registers last, so it holds the
/// pen when the world is handed back.
@MainActor
private func twoTabWorld(
    _ session: AppSession
) async throws -> (
    editors: MobileLivenessAuthority,
    shelf: MobileEditorViewModel, shelfStorage: NSTextStorage,
    library: MobileEditorViewModel
) {
    let post = try await session.runner.run { ops in
        try ops.createPost(title: "two tabs", profile: .blog)
    }
    _ = try await session.runner.run { ops in
        try ops.newBlock(in: post.id, text: "Base.", at: .end)
    }
    let (shelf, shelfStorage) = makeEditor(session, postID: post.id)
    let (library, _) = makeEditor(session, postID: post.id)
    let editors = MobileLivenessAuthority()
    await editors.register(shelf, tab: .shelf)
    await shelf.loadOnce()
    await editors.register(library, tab: .library)
    await library.loadOnce()
    return (editors, shelf, shelfStorage, library)
}

@MainActor
@Suite("Mobile liveness — the authority (S3 ladder fix)")
struct MobileLivenessTests {

    // MARK: The fix round — the architectural review's MAJOR 2

    /// **THE LAST REQUESTED TAB WINS, NOT THE LAST COMPLETED TASK.**
    ///
    /// The shell assigns `tab` synchronously at the tap and hands the
    /// liveness handoff to an unstructured `Task` that suspends twice on
    /// database work (a pending flush, then a fresh read). Two quick taps —
    /// Shelf → Library → Shelf — therefore left two independent tasks in
    /// the air, each carrying the tab it captured at spawn, with nothing
    /// capturing an order: whichever finished LAST installed the liveness
    /// that stood.
    ///
    /// This drives exactly that shape: two handoffs REQUESTED in order, the
    /// stale one COMPLETING last (which is what a slow flush on the leaving
    /// editor produces). Ordering is expressed through the tokens rather
    /// than by racing a real database, deliberately — a pin about ordering
    /// must not itself depend on timing to fail.
    ///
    /// Both wrong end states the review traced are held here: the visible
    /// editor stood down (*"I tap into my note and it won't let me type"*),
    /// and a HIDDEN editor holding the pen — which is the exact law this
    /// authority's own header says it exists to enforce.
    @Test func theLastRequestedTabWinsEvenWhenTheStaleHandoffLandsLast() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "two tabs", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (shelfEditor, shelfStorage) = makeEditor(session, postID: post.id)
            let (libraryEditor, libraryStorage) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(shelfEditor, tab: .shelf)
            await editors.register(libraryEditor, tab: .library)
            await shelfEditor.loadOnce()
            await libraryEditor.loadOnce()

            // Two taps, in this order: to Library, then straight back to
            // Shelf. The tokens are minted at the taps, synchronously, the
            // way the tab door mints them.
            let toLibrary = editors.beginHandoff()
            let toShelf = editors.beginHandoff()

            // The SHELF handoff completes first; the stale LIBRARY one
            // completes last — the ordering a stalled flush produces.
            await editors.tabDidBecomeVisible(.shelf, handoff: toShelf)
            await editors.tabDidBecomeVisible(.library, handoff: toLibrary)

            #expect(editors.live === shelfEditor,
                    "liveness follows the last REQUESTED tab")
            #expect(shelfEditor.isLive)
            #expect(!libraryEditor.isLive,
                    "the hidden stack's editor must not hold the pen")

            // The user-visible half, driven through the real gate: she taps
            // into the note she is LOOKING at and types.
            #expect(
                typeEdit(
                    shelfEditor, shelfStorage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "the visible editor must accept a keystroke")
            #expect(
                !typeEdit(
                    libraryEditor, libraryStorage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "the hidden editor's gate must refuse")
        }
    }

    /// The mirror, so neither direction is a coincidence: the same two
    /// requests with the SHELF one stale still ends with Library live.
    @Test func theMirrorHoldsToo_libraryRequestedLastKeepsThePen() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "two tabs", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (shelfEditor, _) = makeEditor(session, postID: post.id)
            let (libraryEditor, _) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(shelfEditor, tab: .shelf)
            await editors.register(libraryEditor, tab: .library)
            await shelfEditor.loadOnce()
            await libraryEditor.loadOnce()

            let toShelf = editors.beginHandoff()
            let toLibrary = editors.beginHandoff()
            await editors.tabDidBecomeVisible(.library, handoff: toLibrary)
            await editors.tabDidBecomeVisible(.shelf, handoff: toShelf)

            #expect(editors.live === libraryEditor)
            #expect(libraryEditor.isLive)
            #expect(!shelfEditor.isLive)
        }
    }

    // MARK: The INTERIOR arms (the Fable sweep's finding 7)

    /// **A GRANT SUPERSEDED WHILE IT IS SUSPENDED INSTALLS NOTHING.**
    ///
    /// The two pins above drive the AT-ENTRY `isCurrent` check: they mint
    /// both tokens up front and run the grants sequentially, so no newer
    /// request ever arrives mid-flight. The sweep's finding 7 named that
    /// honestly — the record says the token is *"checked at entry AND after
    /// every suspension"* and only the entry half was pinned. These two pins
    /// close the other half, one arm each.
    ///
    /// **Ordering is expressed through a SEAM, never a timing race** (the
    /// A2 pins' own discipline, applied to a harder shape). The seam is the
    /// coordinator's `onSettled`, which fires SYNCHRONOUSLY at the tail of
    /// `flushNow` — i.e. while `takeLiveness` is still inside its `await`
    /// and has not reached the guard that follows it. Bumping the generation
    /// from there is exactly "a second `beginHandoff` landed mid-flight",
    /// with nothing left to chance: no sleeps, no yields, no assumption
    /// about how long a database write takes.
    ///
    /// This one drives the arm after the FLUSH (`MobileLivenessAuthority`'s
    /// first post-suspension guard). The superseded grant must not hand the
    /// pen over — the second wrong end state the authority's header forbids,
    /// a HIDDEN editor holding it, is exactly what an unguarded resume
    /// produces here.
    ///
    /// **Red-on-old — and R2-4 MEASURED exactly which revert reds it, which
    /// corrected the record:** removing BOTH post-suspension `guard
    /// isCurrent` lines reds this pin. Removing the post-FLUSH one ALONE
    /// does NOT — on a `refresh: true` grant the post-REFRESH guard sits
    /// downstream on the same road and catches the bump anyway. So this pin
    /// proves the PAIR, not its own arm; the arm it names is isolated by
    /// `aRefreshlessGrantSupersededDuringItsFlushInstallsNothing` below,
    /// which runs the refreshless road where the post-flush guard is the
    /// only one there is.
    @Test func aGrantSupersededDuringItsFlushInstallsNothing() async throws {
        try await withEditorWorld { session, _ in
            let world = try await twoTabWorld(session)
            let editors = world.editors
            #expect(!world.shelf.isLive && world.library.isLive,
                    "the library editor holds the pen before the grant")

            // The shelf's grant is requested…
            let token = editors.beginHandoff()
            // …and a NEWER request lands while it is suspended at its flush.
            let bump = SupersedeOnSettle(at: 1, editors: editors)
            let observer = world.shelf.autosave.observe(onSettled: bump.fire)
            defer { world.shelf.autosave.stopObserving(observer) }

            await editors.takeLiveness(world.shelf, refresh: true, handoff: token)

            #expect(bump.fired, "the seam really fired — this pin proves nothing otherwise")
            #expect(!world.shelf.isLive,
                    "the superseded grant must not hand the pen to the tab she left")
            #expect(!world.library.isLive,
                    "and the stood-down editor stays down — at most one is the law")
            #expect(
                !typeEdit(
                    world.shelf, world.shelfStorage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "the abandoned grant's editor gate refuses, as a stood-down surface must")
        }
    }

    /// The SECOND interior arm: superseded during the REFRESH, after the
    /// flush guard has already passed. `refreshTakesFromStore` opens with a
    /// `flushNow` of its own, so the same seam fires a second time — inside
    /// the refresh, between the two guards. Bumping there exercises the arm
    /// the first pin cannot reach.
    ///
    /// **Red-on-old: the POST-REFRESH guard alone**, measured (R2-4) — this
    /// is the one pin of the three that isolates a single line.
    @Test func aGrantSupersededDuringItsRefreshInstallsNothing() async throws {
        try await withEditorWorld { session, _ in
            let world = try await twoTabWorld(session)
            let editors = world.editors

            let token = editors.beginHandoff()
            let bump = SupersedeOnSettle(at: 2, editors: editors)
            let observer = world.shelf.autosave.observe(onSettled: bump.fire)
            defer { world.shelf.autosave.stopObserving(observer) }

            await editors.takeLiveness(world.shelf, refresh: true, handoff: token)

            #expect(bump.fired,
                    "the refresh's own flush settled — the second seam really fired")
            #expect(!world.shelf.isLive,
                    "a grant superseded after its refresh installs nothing either")
            #expect(!world.library.isLive)
        }
    }

    /// **THE POST-FLUSH GUARD, ISOLATED — on the road where it is the only
    /// guard there is.** (R2-4's measurement, and finding 7's third arm.)
    ///
    /// R2-4 asked for the per-guard reverts to be RUN rather than traced,
    /// and running them said something the trace had not: on a
    /// `refresh: true` grant the two post-suspension guards sit in series,
    /// so removing the FIRST changes nothing an assertion can see — the
    /// second catches the same bump. Only the joint removal reds the two
    /// pins above.
    ///
    /// A REFRESHLESS grant has no second guard: the flush guard is the last
    /// thing between an abandoned grant and the pen. That is the shape
    /// `register` uses in production (`takeLiveness(_, refresh: false)` —
    /// a newcomer holds nothing yet, so there is nothing to re-read), so
    /// this drives the arm exactly where it is load-bearing.
    ///
    /// **What this pin deliberately does NOT do, traced while building it:**
    /// drive `register` itself. `isLive` starts TRUE on a fresh
    /// `MobileEditorViewModel` (a screen with no authority must be able to
    /// type), and `takeLiveness` stands down OTHERS, never its own taker —
    /// so a superseded registration leaves the newcomer live by default and
    /// the end state is indistinguishable from a granted one through this
    /// surface. Finding 7's third arm (*"`register`'s self-minted token"*)
    /// therefore stays traced-sound and undriven for a reason worth
    /// recording: not a missing seam, an unobservable difference.
    ///
    /// **Red-on-old:** remove the post-FLUSH `guard isCurrent(token)` alone
    /// and the superseded grant takes the pen.
    @Test func aRefreshlessGrantSupersededDuringItsFlushInstallsNothing() async throws {
        try await withEditorWorld { session, _ in
            let world = try await twoTabWorld(session)
            let editors = world.editors
            #expect(!world.shelf.isLive && world.library.isLive,
                    "the library editor holds the pen before the grant")

            let token = editors.beginHandoff()
            let bump = SupersedeOnSettle(at: 1, editors: editors)
            let observer = world.shelf.autosave.observe(onSettled: bump.fire)
            defer { world.shelf.autosave.stopObserving(observer) }

            await editors.takeLiveness(world.shelf, refresh: false, handoff: token)

            #expect(bump.fired, "the seam really fired — this pin proves nothing otherwise")
            #expect(!world.shelf.isLive,
                    "superseded at the only guard on this road, so it never got the pen")
            #expect(!world.library.isLive,
                    "and the stood-down editor stays down — at most one is the law")
            #expect(
                !typeEdit(
                    world.shelf, world.shelfStorage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "the abandoned grant's editor gate refuses, as a stood-down surface must")
        }
    }

    // MARK: The BLOCKER pin — the adjudicated loss script

    /// Type in A → tab-switch inside the debounce → type in B (a second
    /// editor on the SAME post, the alive-stacks shape) → NOTHING lost.
    /// On the pre-fix mechanism (per-VM coordinators; liveness taken
    /// without the flush) B reads a stale photograph, builds on it, and
    /// its flush permanently clobbers A's typing.
    @Test func typingSurvivesTheTabSwitchRoundTrip_nothingLost() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "both tabs", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }

            // Editor A on the shelf stack.
            let (a, storageA) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(a, tab: .shelf)
            await a.loadOnce()

            // Typed in A; the debounce is held open (the harness clock
            // never fires) — exactly the state at a quick tab switch.
            typeEdit(
                a, storageA,
                range: NSRange(location: ("Base." as NSString).length, length: 0),
                replacement: " Typed-in-A.")
            #expect(a.autosave.isDirty)

            // The tab switch: no editor on the library stack yet — A
            // stands down (read-tier; its gate's liveness belt refuses).
            await editors.tabDidBecomeVisible(.library)
            #expect(!a.isLive)
            #expect(editors.live == nil)
            let refused = typeEdit(
                a, storageA,
                range: NSRange(location: 0, length: 0), replacement: "x")
            #expect(!refused, "a stood-down surface's gate refuses")
            #expect(a.statusMessage != nil, "the liveness refusal speaks")

            // Editor B opens the SAME post from the Library listing.
            // Registration takes liveness: the shared per-post coordinator
            // flushes A's pending text BEFORE B reads.
            let (b, storageB) = makeEditor(session, postID: post.id)
            #expect(b.autosave === a.autosave,
                    "one post, ONE coordinator — the N3 boundary on the phone")
            await editors.register(b, tab: .library)
            await b.loadOnce()
            #expect(storageB.string.contains("Typed-in-A."),
                    "B's surface builds on A's typing, never a stale photograph")

            // Type in B, flush — the store holds BOTH edits.
            typeEdit(
                b, storageB,
                range: NSRange(location: storageB.length, length: 0),
                replacement: " Typed-in-B.")
            await b.autosave.flushNow()
            #expect(try await storedText(db, variantID: minted.variant.id)
                    == "Base. Typed-in-A. Typed-in-B.",
                    "NOTHING typed is ever lost — the forbidden outcome refused")
        }
    }

    /// Tab re-entry (the round trip's other half): returning to a stack
    /// whose editor went stale while the other tab edited the same post
    /// re-reads fresh BEFORE granting the pen.
    @Test func tabReEntryRefreshesTheStaleSurfaceBeforeThePen() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "re-entry", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (a, storageA) = makeEditor(session, postID: post.id)
            let (b, storageB) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(a, tab: .shelf)
            await a.loadOnce()
            await editors.register(b, tab: .library)
            await b.loadOnce()

            // B edits (live); A's surface is now a stale photograph.
            typeEdit(
                b, storageB,
                range: NSRange(location: ("Base." as NSString).length, length: 0),
                replacement: " Typed-in-B.")
            #expect(storageA.string == "Base.")

            // Back to the shelf tab: A takes liveness WITH the refresh.
            await editors.tabDidBecomeVisible(.shelf)
            #expect(a.isLive)
            #expect(!b.isLive)
            #expect(storageA.string.contains("Typed-in-B."),
                    "re-entry lands the sibling's text before the next keystroke")
            _ = db
        }
    }

    // MARK: The tombstone — no pen over a note that is gone (4.5c-phone item 2)

    /// **SHE DELETES THE NOTE FROM THE LIBRARY; THE OTHER TAB'S EDITOR IS
    /// STILL STANDING ON IT.**
    ///
    /// Both stacks stay alive by design, so the shelf stack's
    /// `MobileWriteScreen` survives a delete performed on the Library tab —
    /// and §49's filed remedy (*"the Library row door passes no
    /// `onDeleted`"*) reaches nothing, because the stale surface is not in the
    /// stack that would pop. The next tab tap then ran the ordinary grant and
    /// handed that surface the pen, so keystrokes autosaved into a tombstoned
    /// note's variants: bytes written where no listing will ever show them.
    ///
    /// The refusal belongs at the one act that hands a surface the pen, which
    /// is what this drives — `tabDidBecomeVisible`, the real road, not the
    /// editor's own flag.
    ///
    /// **The keystroke is driven through the REAL GATE** (`typeEdit`), never
    /// `UITextView.deleteBackward()`/`replace(_:withText:)`, which bypass it
    /// (§5.1's trap).
    ///
    /// **RED ON OLD (production — `MobileLivenessAuthority.takeLiveness`'s two
    /// new guards + `MobileEditorViewModel`'s `noteIsGone`):** the grant lands,
    /// `editors.live` is the shelf editor, `isLive` is true, and the gate
    /// ACCEPTS the keystroke into the tombstone. Quoted in the batch record.
    @Test func aNoteDeletedOnTheOtherTabNeverGetsThePenBack() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "deleted under her", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (shelf, shelfStorage) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(shelf, tab: .shelf)
            await shelf.loadOnce()
            #expect(shelf.isLive && !shelf.noteIsGone, "the ordinary state first")

            // She taps to the Library tab: the shelf editor stands down (no
            // editor on that stack, so nobody holds the pen).
            await editors.tabDidBecomeVisible(.library)
            #expect(!shelf.isLive)

            // …and deletes the note from a Library row. This is the door's own
            // op; nothing tells the shelf stack anything.
            try await session.runner.run { ops in try ops.deleteContainer(post.id) }

            // Back to the shelf tab — the tap that used to hand over the pen.
            await editors.tabDidBecomeVisible(.shelf)

            #expect(editors.live == nil, "nobody holds the pen over a tombstone")
            #expect(!shelf.isLive)
            #expect(shelf.noteIsGone, "and the surface knows why, from the store")
            #expect(
                !typeEdit(
                    shelf, shelfStorage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "the gate refuses a keystroke into a deleted note")
            #expect(shelf.statusMessage == MobileEditorViewModel.deletedNoteRefusal,
                    "and it SAYS so — naming the Trash, not a seal")
            #expect(try await storedText(db, variantID: minted.variant.id) == "Base.",
                    "nothing was written into the tombstoned note")
        }
    }

    /// **THE LIVE SURFACE RELINQUISHES, TOO** — the sync road (deleted on the
    /// Mac while she is looking at it on the phone), which no tab tap
    /// mediates. The store's answer reaches the surface through the one
    /// header door, and the keyboard goes with it.
    ///
    /// **RED ON OLD:** `adoptHeader`'s relinquish half + the gate's tombstone
    /// belt. Pre-fix the editor keeps the pen and the gate accepts.
    @Test func aNoteDeletedUnderALiveEditorStopsAcceptingKeystrokes() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "deleted beneath her", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            #expect(
                typeEdit(
                    model, storage,
                    range: NSRange(location: ("Base." as NSString).length, length: 0),
                    replacement: " typed"),
                "the control: this surface accepts keystrokes while its note lives")
            await model.autosave.flushNow()

            // The note goes elsewhere (sync, or the Library on the other tab);
            // the header observation is what tells this surface, and
            // `loadOnce` drives that same door deterministically.
            try await session.runner.run { ops in try ops.deleteContainer(post.id) }
            await model.loadOnce()

            #expect(model.noteIsGone)
            #expect(
                !typeEdit(
                    model, storage,
                    range: NSRange(location: 0, length: 0), replacement: "x"),
                "a surface whose note went stops taking keystrokes")
            #expect(model.statusMessage == MobileEditorViewModel.deletedNoteRefusal)
            #expect(try await storedText(db, variantID: minted.variant.id) == "Base. typed",
                    "and the words she typed BEFORE it went are untouched")
        }
    }

    /// **THE ENTRY GUARD, ISOLATED — and it took a measurement to find a way**
    /// (the R2-4 discipline, applied to this item's own pair).
    ///
    /// `takeLiveness` refuses a tombstone twice: cheaply at ENTRY, on what the
    /// surface already knows from its last header delivery, and again after
    /// its suspensions through an authoritative store read. Reverting each
    /// half separately (recorded in the batch record) showed that on the
    /// tab-tap road the **post-suspension read carries the pin alone** — the
    /// entry guard fires there not at all, because nothing had told the
    /// surface yet. Both reverts reddened `aNoteDeletedOnTheOtherTabNeverGets
    /// ThePenBack` identically, so that pin proves the PAIR, not its arms.
    ///
    /// This isolates the entry arm on the road where it is the one that acts:
    /// the surface ALREADY knows (its header observation delivered while the
    /// tab was hidden — the production case the harness cannot run, driven
    /// here through the same one door the observation uses). Its effect is
    /// that the grant stops BEFORE doing store work, which the coordinator's
    /// settle seam can see: with the guard, zero flushes; without it, the
    /// grant flushes and re-reads before discovering what it already knew.
    ///
    /// **RED ON OLD:** remove the entry `guard !editor.noteIsGone` alone and
    /// `settles` is non-zero. (The end state is the same either way — the
    /// second guard catches it — which is exactly why this pin watches the
    /// WORK rather than the outcome.)
    @Test func aGrantForAKnownTombstoneStopsBeforeDoingAnyStoreWork() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "known gone", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (model, _) = makeEditor(session, postID: post.id)
            let editors = MobileLivenessAuthority()
            await editors.register(model, tab: .shelf)
            await model.loadOnce()

            // The note goes, and the surface's header door hears about it —
            // in production the observation loop; here the same door, driven.
            try await session.runner.run { ops in try ops.deleteContainer(post.id) }
            await model.loadOnce()
            #expect(model.noteIsGone, "the surface already knows before the grant")

            var settles = 0
            let observer = model.autosave.observe(onSettled: { settles += 1 })
            defer { model.autosave.stopObserving(observer) }

            await editors.tabDidBecomeVisible(.shelf)

            #expect(settles == 0,
                    "the grant refused at entry — no flush, no re-read for a note it knows is gone")
            #expect(editors.live == nil)
            #expect(!model.isLive)
        }
    }

    /// **AND IT HEALS.** A Put back from the Trash makes the note real again,
    /// and the surface standing on it takes keystrokes again — which is the
    /// whole reason `noteIsGone` is kept apart from `isLive` rather than
    /// latching the authority's own flag.
    ///
    /// **NOT A RED-ON-OLD PIN, and it says so rather than claiming one.** It
    /// is a control against a WRONG FIX: an implementation that answered the
    /// two pins above by latching `isLive` would fail this one, leaving her
    /// looking at a restored note she cannot type in. On the pre-fix tree it
    /// fails only at its own `noteIsGone` precondition — i.e. at machinery
    /// that did not exist there — which is not evidence about a defect and is
    /// recorded as such (measured, not assumed; the batch record carries the
    /// output).
    @Test func puttingTheNoteBackLetsItsSurfaceWriteAgain() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "put back", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Base.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            try await session.runner.run { ops in try ops.deleteContainer(post.id) }
            await model.loadOnce()
            #expect(model.noteIsGone)

            // The Trash's Put back.
            try await session.runner.run { ops in try ops.restoreContainer(post.id) }
            await model.loadOnce()

            #expect(!model.noteIsGone)
            // INSIDE the block, deliberately: an empty render leaves a
            // zero-length open tail behind it, so an edit at the document's
            // very end would land in the tail and wait on a crystallization —
            // true of the shipped editor, and nothing to do with this fix.
            #expect(
                typeEdit(
                    model, storage,
                    range: NSRange(location: 1, length: 0), replacement: "X"),
                "the surface writes again with no further grant")
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: minted.variant.id) == "BXase.")
        }
    }

    // MARK: MAJOR 1 — the background flush covers every registered editor

    @Test func theBackgroundFlushCoversEveryRegisteredEditor_bothArms() async throws {
        try await withEditorWorld { session, db in
            // Two posts, one editor each — registration order A then B, so
            // a single-slot mechanism would cover only B.
            let postA = try await session.runner.run { ops in
                try ops.createPost(title: "shelf note", profile: .blog)
            }
            let mintedA = try await session.runner.run { ops in
                try ops.newBlock(in: postA.id, text: "A", at: .end)
            }
            let postB = try await session.runner.run { ops in
                try ops.createPost(title: "library note", profile: .blog)
            }
            let mintedB = try await session.runner.run { ops in
                try ops.newBlock(in: postB.id, text: "B", at: .end)
            }

            let (a, storageA) = makeEditor(session, postID: postA.id)
            let editors = MobileLivenessAuthority()
            await editors.register(a, tab: .shelf)
            await a.loadOnce()
            typeEdit(
                a, storageA,
                range: NSRange(location: 1, length: 0), replacement: " typed")
            #expect(a.autosave.isDirty)

            // Arm (a): a second editor registered LATER — the earlier one
            // must still be a flush target.
            let (b, storageB) = makeEditor(session, postID: postB.id)
            await editors.register(b, tab: .library)
            await b.loadOnce()
            typeEdit(
                b, storageB,
                range: NSRange(location: 1, length: 0), replacement: " typed")

            await performBackgroundFlush(editors: editors, sync: nil)
            #expect(try await storedText(db, variantID: mintedA.variant.id) == "A typed",
                    "arm (a): the EARLIER-registered editor's burst lands too")
            #expect(try await storedText(db, variantID: mintedB.variant.id) == "B typed")

            // Arm (b): pop the later editor — the survivor is still
            // covered (a single slot would be nil here and flush nothing).
            editors.deregister(b)
            await editors.tabDidBecomeVisible(.shelf)
            typeEdit(
                a, storageA,
                range: NSRange(location: ("A typed" as NSString).length, length: 0),
                replacement: " more")
            #expect(a.autosave.isDirty)
            await performBackgroundFlush(editors: editors, sync: nil)
            #expect(try await storedText(db, variantID: mintedA.variant.id) == "A typed more",
                    "arm (b): a pop never empties the flush coverage")
        }
    }

    // MARK: MAJOR 2 — arrival raises focus (wiring before the infinite loops)

    /// The Today door's "cold launch → typing in two taps", made true and
    /// pinned (window-hosted — the S2 focus-pin pattern): `arrive` returns
    /// with focus risen; the observation loops start AFTER it, so the
    /// raise can never sit behind a `start()` that never returns.
    @Test func arrivalRaisesFocusBeforeTheObservationLoops() async throws {
        try await withEditorWorld { session, _ in
            let entry = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: "2026-08-03")
            }
            let model = MobileEditorViewModel(
                session: session, postID: entry.container.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }

            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            window.addSubview(surface)
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            model.attach(textView: surface.textView)

            // The screen's exact wiring order: arrive first, loops after.
            // The wait is BOUNDED (the house pattern) so the pre-fix
            // mechanism — focus sequenced after a start() that never
            // returns — fails red instead of hanging.
            let arrival = Task { await model.arrive(focus: true) }
            var rose = false
            for _ in 0..<400 where !rose {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
                rose = surface.textView.isFirstResponder
            }
            arrival.cancel()
            #expect(rose, "arrival raises the keyboard — two taps to typing")
        }
    }

    // MARK: MINOR 2 — the voice flip reaches every registered editor

    @Test func aVoiceFlipReachesEveryRegisteredEditor() async throws {
        try await withEditorWorld { session, _ in
            let suite = "MobileLivenessTests-voice-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer {
                defaults.removePersistentDomain(forName: suite)
                MobileEditorStyle.voice = .terminal
            }
            let postA = try await session.runner.run { ops in
                try ops.createPost(title: "voiced A", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: postA.id, text: "Voiced A.", at: .end)
            }
            let postB = try await session.runner.run { ops in
                try ops.createPost(title: "voiced B", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: postB.id, text: "Voiced B.", at: .end)
            }
            let (a, storageA) = makeEditor(session, postID: postA.id)
            let (b, storageB) = makeEditor(session, postID: postB.id)
            let router = MobileShellRouter(defaults: defaults)
            await router.editors.register(a, tab: .shelf)
            await a.loadOnce()
            await router.editors.register(b, tab: .library)
            await b.loadOnce()
            #expect(!a.isLive && b.isLive, "exactly one live editor anywhere")

            // The flip window: synchronous end to end (the S1 MINOR-2
            // discipline — no suspension point between flip and asserts).
            router.setVoice(.study)
            let fontA = storageA.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            let fontB = storageB.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(fontA == MobileEditorStyle.studyFace.body,
                    "the STOOD-DOWN editor's storage follows the flip too")
            #expect(fontB == MobileEditorStyle.studyFace.body)
            router.setVoice(.terminal)
            let backA = storageA.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            let backB = storageB.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(backA == MobileEditorStyle.terminalFace.body)
            #expect(backB == MobileEditorStyle.terminalFace.body)
        }
    }
}
