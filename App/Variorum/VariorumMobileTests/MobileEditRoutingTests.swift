//
//  MobileEditRoutingTests.swift
//  VariorumMobileTests
//
//  Mobile round 2, batch 1 — the delete-at-the-end crash's PINS, the half
//  that does NOT kill the test process on the pre-fix tree. The two exact
//  crash reproductions (and the closed-tail sibling) live in
//  `MobileEditRoutingCrashTests.swift`, because on pre-fix code they die
//  inside `BlockRangeIndex`'s preconditions and a dying process takes the
//  whole suite's report down with it.
//
//  THE MECHANISM these pin (traced in `notes/plans/mobile-round-2-crash-
//  trace.md`, proven from her two 2026-08-20 iPhone logs by symbolication
//  AND disassembly of the shipped binary): `shouldChangeText` computes a
//  verdict against the PRE-edit index and parks it; `storageDidEdit` takes
//  the IDENTITY from that parked answer and the MAGNITUDE from the
//  storage's own report, and nothing checked the two described the same
//  edit. The headline pin below is the clean oracle for the fix — it needs
//  no crash at all, which is the point: the crash was one symptom of
//  wrong bookkeeping, and the wrong bookkeeping is what got fixed.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The shared fixture (the crash trace's §5 document)

/// Three blocks + a freshly-typed open tail:
/// `"Alpha\nBeta beta\nGamma\ndelta"` — entries 5 / 9 / 5, tail 5,
/// documentLength 27, tailRange (22, 5). The trace's worked numeric
/// example runs on exactly this shape.
@MainActor
func editRoutingFixture(
    _ session: AppSession
) async throws -> (model: MobileEditorViewModel, storage: NSTextStorage, postID: String) {
    let post = try await session.runner.run { ops in
        try ops.createPost(title: "edit routing", profile: .blog)
    }
    for text in ["Alpha", "Beta beta", "Gamma"] {
        _ = try await session.runner.run { ops in
            try ops.newBlock(in: post.id, text: text, at: .end)
        }
    }
    let (model, storage) = makeEditor(session, postID: post.id)
    await model.loadOnce()
    typeAtEnd(model, storage, "\n")      // opens the tail
    typeAtEnd(model, storage, "delta")   // fills it
    return (model, storage, post.id)
}

/// A gate-LESS storage edit — the shape iOS's system paths really use
/// (autocorrect's `replace(_:withText:)`, dictation revision, a
/// marked-text commit). No `shouldChangeText` call precedes it, which is
/// exactly why a stale arming gets consumed by it.
@MainActor
func systemPathEdit(_ storage: NSTextStorage, range: NSRange, replacement: String) {
    storage.replaceCharacters(
        in: range,
        with: NSAttributedString(
            string: replacement, attributes: [.font: MobileEditorStyle.baseFont]))
}

/// Runs `body` with the editor's debug assertions muted (the
/// `MobileFallbackCanary` N2 pattern). A pin that exercises an honest
/// RECOVERY road must not be stopped by the assertion that announces it;
/// the models' counters are the oracle instead.
///
/// The mute is TASK-SCOPED (round-2 ladder round 1, MINOR 4): this body
/// holds it across hundreds of `await`s, and Swift Testing runs suites in
/// parallel — a process-global handler would silently disable the editor's
/// Debug assertions inside whatever other `@MainActor` test was scheduled
/// during a suspension. A task-local binding reaches this body and the
/// tasks spawned inside it (which is exactly `desyncRecovery`'s heal) and
/// nothing else.
@MainActor
func withEditorAssertionsMuted<T>(_ body: () async throws -> T) async rethrows -> T {
    try await EditorAssertionSeam.$handler.withValue({ _, _, _ in }) {
        try await body()
    }
}

/// Spins the main actor until `condition` holds or the budget runs out
/// (the house pattern — `desyncRecovery` heals through an async read).
@MainActor
func settleEditor(until condition: () -> Bool, spins: Int = 400) async {
    for _ in 0..<spins {
        if condition() { return }
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}

// MARK: - The binding (P1 — the headline)

@MainActor
@Suite("Mobile edit routing — the verdict is bound to its edit (round 2, M1)")
struct MobileEditRoutingBindingTests {
    @Test func theFixtureIsTheTracesDocument() async throws {
        try await withEditorWorld { session, _ in
            let world = try await editRoutingFixture(session)
            #expect(world.storage.string == "Alpha\nBeta beta\nGamma\ndelta")
            #expect(world.model.index.entries.map(\.length) == [5, 9, 5])
            #expect(world.model.index.tailLength == 5)
            #expect(world.model.index.documentLength == 27)
            #expect(world.model.index.tailRange == NSRange(location: 22, length: 5))
            #expect(world.model.index.documentLength == world.storage.length)
            #expect(world.model.desyncRecoveryCount == 0)
            #expect(world.model.identityAuditFailures == 0)
        }
    }

    /// **P1 — the pin the whole fix is for.** A verdict armed for an edit
    /// that never lands must not be applied to the edit that lands next.
    ///
    /// The arming-without-landing shape is real and in the code today:
    /// `MobileMarkdownActs.handleReturnKey`'s `.continueList` arm calls
    /// `gateAllows` and then early-returns when the newline did not land,
    /// leaving the slot armed; `inputReplace` and `performTabKey` arm and
    /// then hand off to UIKit. The edit that follows is a gate-LESS system
    /// path (autocorrect / dictation / a marked-text commit), which is the
    /// one road that reads the parked slot without first overwriting it.
    ///
    /// RED ON THE PRE-FIX TREE, with no process death: the stale
    /// `.block(0)` is consumed, so `entries[0]` SHRINKS to 4 while
    /// `entries[1]` — the block the characters actually left — stays 9.
    /// The index still tiles the storage by total LENGTH, so nothing
    /// traps; the identity projection is simply wrong, and the audit sees
    /// it. That quiet version of the bug is why the fix is the BINDING and
    /// not just a fallible mutator.
    ///
    /// The landing is a DELETION deliberately: iOS's attribute fixing
    /// widens an insertion's `didProcessEditing` report (measured here —
    /// a one-character insert mid-paragraph reported `{8, 9}`), while a
    /// deletion's report is exact. A widened gate-less report can already
    /// overflow its entry and take the honest recovery road, which is
    /// correct but is a different story from this one; the deletion keeps
    /// the pin on the binding alone.
    @Test func aStaleVerdictIsNotAppliedToTheNextEdit() async throws {
        try await withEditorWorld { session, _ in
            try await withEditorAssertionsMuted {
                let world = try await editRoutingFixture(session)
                let model = world.model
                let storage = world.storage

                // Arm a verdict for an edit that never reaches storage.
                #expect(model.shouldChangeText(
                    in: NSRange(location: 0, length: 1), replacement: "X"))

                // …then land an unrelated one-character deletion inside
                // block 1, through a path that consults no gate.
                systemPathEdit(storage, range: NSRange(location: 8, length: 1), replacement: "")

                #expect(storage.string == "Alpha\nBea beta\nGamma\ndelta")
                #expect(model.index.entries[1].length == 8,
                        "the edit's own block shrank")
                #expect(model.index.entries[0].length == 5,
                        "the stale verdict's block is untouched")
                #expect(model.index.entries[2].length == 5)
                #expect(model.index.tailLength == 5)
                #expect(model.index.documentLength == storage.length,
                        "the index still tiles the storage exactly")
                #expect(model.identityAuditFailures == 0,
                        "identity did not silently drift onto the wrong block")
                #expect(model.desyncRecoveryCount == 0,
                        "a rejected arming is not a refusal — the report routes by fallback")
            }
        }
    }

    /// **The round-2 ladder's MAJOR 1, pinned.** The first binding bounded
    /// the report's MAGNITUDE and its START — never its EXTENT. So a
    /// transaction that begins inside the approved range and runs PAST the
    /// region's end was still consumed, as long as it removed no more
    /// characters than the approval held.
    ///
    /// Her own stack names this shape:
    /// `_deleteBackwardAndNotify:reinsertText:overrideOriginalContext…` is
    /// a delete COMPOSED WITH A REINSERTION, and her transactions
    /// demonstrably crossed two separators. Here the gate approves
    /// `(16, 5)` → `""` (delete "Gamma", net −5) and one transaction
    /// replaces `(16, 11)` — "Gamma\ndelta", crossing the tail separator —
    /// with seven characters, reporting `editedRange (16, 7)`, `delta −4`.
    ///
    /// RED ON THE PRE-FIX TREE, and quietly: 4 ≤ 5 so the old guard
    /// passed, `applyBlockEdit(at: 2, lengthDelta: −4)` succeeded (5 − 4 =
    /// 1 ≥ 0, no trap), and afterwards `index.documentLength` and
    /// `storage.length` AGREE at 23 — so the totals check everything
    /// downstream leans on is satisfied, `restampProjection` stamps
    /// consistently with the corrupted index, and the Debug identity audit
    /// computes clean. Then `recordAutosave(entryIndex: 2, …)` reads
    /// `viewText((16, 1))` and writes her whole paragraph "Gamma" to the
    /// store as ONE CHARACTER — through the ledger, so echo detection
    /// never notices. **That is worse than the crash this batch fixed: a
    /// crash is loud and loses nothing committed; this loses her prose in
    /// silence.**
    ///
    /// GREEN AFTER: the net change (−4) is not the approved one (−5), the
    /// arming is declined, and `fallbackVerdict` recomputes `(16, 11)`
    /// against the pre-edit index — a span crossing block 2 into the tail,
    /// which no region contains — so the honest road runs and the store is
    /// untouched.
    @Test func aComposedTransactionWiderThanItsApprovalIsNotConsumed() async throws {
        try await withEditorWorld { session, db in
            try await withEditorAssertionsMuted {
                let world = try await editRoutingFixture(session)
                let model = world.model
                let storage = world.storage
                let before = try await storedBlockTexts(db, postID: world.postID)
                #expect(before == ["Alpha", "Beta beta", "Gamma"])

                // The gate approves deleting exactly the third block.
                #expect(model.shouldChangeText(
                    in: NSRange(location: 16, length: 5), replacement: ""))

                // …and one coalesced transaction replaces eleven characters
                // — across the tail separator — with seven.
                storage.beginEditing()
                storage.replaceCharacters(
                    in: NSRange(location: 16, length: 11), with: "Gamma??")
                storage.endEditing()

                #expect(model.desyncRecoveryCount == 1,
                        "the un-described transaction took the honest road")
                await settleEditor(until: { model.index.documentLength == storage.length })
                #expect(model.index.documentLength == storage.length,
                        "the surface healed from the store")
                #expect(storage.string == "Alpha\nBeta beta\nGamma\ndelta",
                        "the store is truth: the un-routable transaction did not stand")
                await model.autosave.flushNow()
                #expect(try await storedBlockTexts(db, postID: world.postID) == before,
                        "her paragraph was not overwritten with one character")
            }
        }
    }

    /// The other half of the binding: an arming that DOES describe the
    /// edit that lands is still honored. Without this the pin above could
    /// be satisfied by throwing every arming away, which would retire the
    /// gate's exact churn cost and the open/close-tail gestures with it.
    @Test func anArmingThatStillDescribesItsEditIsHonored() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "honored", profile: .blog)
            }
            let minted = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha beta.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // A policed insertion: gate, then the storage edit it approved.
            typeEdit(model, storage, range: NSRange(location: 5, length: 0), replacement: "!")
            #expect(storage.string == "Alpha! beta.")
            #expect(model.index.entries[0].length == 12)
            #expect(model.index.documentLength == storage.length)
            #expect(model.desyncRecoveryCount == 0)
            #expect(model.identityAuditFailures == 0)
            await model.autosave.flushNow()
            #expect(try await storedText(db, variantID: minted.variant.id) == "Alpha! beta.")
        }
    }

    /// The open/close-tail gestures are armings too — the fixture above
    /// already proves `.openTail` survives the binding (it builds its tail
    /// through the gate), and this pins `.closeTail`'s round trip.
    @Test func theTailGesturesSurviveTheBinding() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "tail gestures", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            typeAtEnd(model, storage, "\n")
            #expect(model.index.tailLength == 0, "the tail opened")
            #expect(model.index.documentLength == storage.length)

            // Backspace over the tail's own separator closes it again.
            let separator = try #require(model.index.tailSeparatorOffset)
            typeEdit(
                model, storage,
                range: NSRange(location: separator, length: 1), replacement: "")
            #expect(model.index.tailLength == nil, "the tail closed")
            #expect(model.index.documentLength == storage.length)
            #expect(storage.string == "Alpha")
            #expect(model.desyncRecoveryCount == 0)
            // The audit's separator-CHARACTER check runs on every one of
            // these keystrokes, and a tail's separator opens and closes
            // under it (round-2 ladder round 2, the M15 Q2 false-positive
            // guard).
            #expect(model.identityAuditFailures == 0)
        }
    }

    /// **VM-5 stability pass, MAJOR 2 — the binding policed geometry and
    /// net change, never CONTENT, and `.openTail` is a content verdict.**
    ///
    /// The gate approves a typed `"\n"` at the exact document end and arms
    /// `.openTail`; the newline never lands (the armed-but-never-landed class
    /// `ArmedEdit`'s own doc names — E1 proved consult/perform mismatches
    /// occur on her hardware). The next report is a GATE-LESS one-character
    /// insert of `"x"` at the same spot (autocorrect / dictation / a
    /// marked-text commit). All three geometry oracles pass — same document
    /// length, net +1 exactly as approved, an empty approval's inclusive
    /// location bound — so the arming BOUND, `index.openTail()` ran, and the
    /// index declared position 5 a separator with an empty tail behind it
    /// while the storage held a visible `"x"` there.
    ///
    /// RED ON THE PRE-FIX TREE (the reviewer's probe 3, measured:
    /// `tailLength=Optional(0) audit=1 desync=0`). In Release the DEBUG
    /// audit is compiled out: the `"x"` is unowned, never autosaved, and
    /// dropped at the next full render — one character of her prose, gone
    /// with no sentence. The flush assertion below is that loss, observed.
    ///
    /// GREEN AFTER: the landed character is not the newline the verdict
    /// means, so the arming is declined and `fallbackVerdict` routes the
    /// report from scratch — `.block(0)`, the block the character joined.
    @Test func aStaleOpenTailArmingNeverBindsAGateLessCharacter() async throws {
        try await withEditorWorld { session, db in
            try await withEditorAssertionsMuted {
                let post = try await session.runner.run { ops in
                    try ops.createPost(title: "open tail content", profile: .blog)
                }
                let minted = try await session.runner.run { ops in
                    try ops.newBlock(in: post.id, text: "Alpha", at: .end)
                }
                let (model, storage) = makeEditor(session, postID: post.id)
                await model.loadOnce()
                #expect(model.index.tailLength == nil, "precondition: no tail yet")

                // The gate approves the tail-opening newline (`.openTail`)…
                #expect(model.shouldChangeText(
                    in: NSRange(location: 5, length: 0), replacement: "\n"))
                // …which never lands; a gate-less "x" arrives instead.
                systemPathEdit(storage, range: NSRange(location: 5, length: 0), replacement: "x")

                #expect(storage.string == "Alphax")
                #expect(model.index.tailLength == nil,
                        "no tail opened: the landed character is not the newline the verdict means")
                #expect(model.index.entries.map(\.length) == [6],
                        "the character joined the block it landed in")
                #expect(model.index.documentLength == storage.length)
                #expect(model.identityAuditFailures == 0,
                        "position 5 is prose, never a separator")
                #expect(model.desyncRecoveryCount == 0,
                        "a declined arming is not a refusal — the report routes by fallback")
                await model.autosave.flushNow()
                let stored = try await storedText(db, variantID: minted.variant.id)
                #expect(stored == "Alphax",
                        "the character reached the store instead of being stranded")
            }
        }
    }

    /// **VM-5 stability pass, MINOR 3 — the leading-run attachment moves the
    /// tiling without disarming the pending edit.** Every other
    /// index-changing door disarms (`renderFull`, `applyDifferential`,
    /// `displaySlot`, `finishMint`); the attachment grows the last entry over
    /// the tail's leading newline run and shrinks the tail by the same
    /// amount, so `documentLength` does not move and `describes`' length
    /// oracle cannot see the tiling change (the reason `displaySlot`'s own
    /// comment gives for disarming structurally).
    ///
    /// **The precondition, produced through production roads only.** On
    /// this platform an UNATTACHED newline-led tail meets a live arming at
    /// the idle tick only after a crystallization that skipped the
    /// attachment ended WITHOUT `finishMint` (whose disarm-then-re-run is the
    /// success road's own protection): a newline typed at the tail's start
    /// while a mint is in flight (the band's `!mintInFlight` guard skips the
    /// attachment), and that mint then FAILS — here because a seal reached
    /// the store the editor has not yet ingested (a seal synced from another
    /// device lands exactly so: deliveries defer while the editor is busy).
    /// The failure arm resets the flight and returns; no disarm, no
    /// attachment. The idle tick then attaches with the stale arming live.
    ///
    /// RED ON THE PRE-FIX TREE: the stale `.tail` arming — approved for the
    /// tail's first character, which the attachment has since made the last
    /// entry's — binds a gate-less deletion there (same length, net −1 as
    /// approved, inside the approved range), so `applyTailEdit` shrinks the
    /// TAIL for a character the BLOCK lost: the separator offset now holds
    /// prose ("o"), the tail reads "ne\ntwo", and the DEBUG audit fires.
    ///
    /// GREEN AFTER: the attachment disarms; the report routes by
    /// `fallbackVerdict` to `.block(0)` — the block the character left.
    @Test func theLeadingRunAttachmentDisarmsAStaleArming() async throws {
        try await withEditorWorld { session, _ in
            try await withEditorAssertionsMuted {
                let post = try await session.runner.run { ops in
                    try ops.createPost(title: "attachment disarm", profile: .blog)
                }
                _ = try await session.runner.run { ops in
                    try ops.newBlock(in: post.id, text: "Alpha", at: .end)
                }
                let (model, storage) = makeEditor(session, postID: post.id)
                await model.loadOnce()
                typeAtEnd(model, storage, "\n")    // opens the tail
                typeAtEnd(model, storage, "one")   // "Alpha\none"

                // A seal reaches the STORE; this editor has not ingested it
                // (no header observation in the harness — the busy-deferral
                // shape), so its gate still admits typing.
                try await session.runner.run { ops in try ops.lockPost(post.id) }

                // Typing past "one" completes a paragraph: a mint flies.
                typeAtEnd(model, storage, "\ntwo")
                #expect(model.mintInFlight, "precondition: a mint is in flight")
                // A blank line typed at the TAIL'S START during the flight:
                // the band's in-flight guard skips the attachment.
                #expect(typeEdit(
                    model, storage, range: NSRange(location: 6, length: 0), replacement: "\n\n"))
                #expect(storage.string == "Alpha\n\n\none\ntwo")
                #expect(model.index.entries.map(\.length) == [5])
                #expect(model.index.tailLength == 9, "precondition: the run is still the tail's")

                // A stale `.tail` arming over the tail's first character —
                // approved, never landed.
                #expect(model.shouldChangeText(
                    in: NSRange(location: 6, length: 1), replacement: ""))

                // The mint FAILS under the seal: the failure arm neither
                // disarms nor attaches.
                await model.awaitMintSettle()
                #expect(!model.mintInFlight)
                #expect(model.index.entries.map(\.length) == [5],
                        "precondition: the mint failed — nothing crystallized")

                // The idle tick: the attachment moves the tiling.
                model.idleMintTail()
                #expect(model.index.entries.map(\.length) == [7],
                        "precondition: the run attached to the last block")
                #expect(model.index.tailLength == 7)
                #expect(storage.string == "Alpha\n\n\none\ntwo", "the bytes never moved")

                // A gate-less deletion where the stale arming pointed.
                systemPathEdit(storage, range: NSRange(location: 6, length: 1), replacement: "")

                #expect(storage.string == "Alpha\n\none\ntwo")
                #expect(model.index.entries.map(\.length) == [6],
                        "the block the character left is the one that shrank")
                #expect(model.index.tailLength == 7, "the tail lost nothing")
                #expect(model.index.documentLength == storage.length)
                #expect(model.identityAuditFailures == 0,
                        "the separator offset still holds the separator")
                #expect(model.desyncRecoveryCount == 0,
                        "a declined arming is not a refusal — the report routes by fallback")
                await model.awaitMintSettle()  // the second mint fails too; let it land
            }
        }
    }
}

// MARK: - M15 Q2: the DEBUG identity audit checks the separator's CHARACTER

/// **The adopted half of M15's boundary check** (round-2 ladder round 2).
/// `auditIdentityProjection` already read storage at every separator offset
/// to assert the separator carries no block ID; it now also asserts the
/// character there IS a separator, and it no longer skips an EMPTY entry's
/// separator entirely.
///
/// **What this buys:** the two oracles that existed are both blind to a
/// tiling that has slipped against the storage's real newlines —
/// `documentLength == storage.length` compares totals (which a mis-routed
/// zero-net edit leaves agreeing), and the attribute walk compares the
/// projection to the index (which `restampProjection` has by then made
/// self-consistent with the corrupted index). The two "fires" pins below
/// construct exactly that state: BOTH old oracles satisfied, the new check
/// the only thing that speaks. They are RED ON THE PRE-FIX AUDIT — it
/// computes clean on both.
///
/// **What it costs is the false-positive risk, and that is the half worth
/// pinning most**, because a DEBUG oracle that cries wolf on legitimate
/// prose gets muted and then protects nothing. Under I4 internal newlines
/// are CONTENT, so a block whose own text ends in a newline is ordinary and
/// must stay silent; so must an empty block, the tail gestures
/// (`theTailGesturesSurviveTheBinding` above), an iOS-widened attribute-fix
/// report (`aWidenedAttributeFixReportNeverPoisonsTheSeparator` in
/// `MobileMarkdownTests`, which drives a real widened report through the
/// real surface), and the 100k typing walk (`MobilePerfWalkTests`).
@MainActor
@Suite("Mobile identity audit — the separator check (round 2, M15 Q2)")
struct MobileIdentityAuditSeparatorTests {
    /// Detaches the model onto a byte-for-byte copy of its own surface with
    /// ONE character changed, attributes preserved. Nothing observes the
    /// mutation (the copy carries no delegate until `attach`), so the model's
    /// index still describes the pre-corruption document — which is the
    /// point: it is the shape a mis-routed edit leaves behind, minus the
    /// mis-routed edit.
    private func corruptSeparator(
        _ model: MobileEditorViewModel, _ storage: NSTextStorage, at offset: Int
    ) -> NSTextStorage {
        let copy = NSTextStorage(attributedString: storage)
        copy.replaceCharacters(in: NSRange(location: offset, length: 1), with: "x")
        model.attach(storage: copy)
        return copy
    }

    @Test func aSeparatorOffsetLandingOnProseFires() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Alpha", "Beta"])
            let (model, storage) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(storage.string == "Alpha\nBeta")
            #expect(model.identityAuditFailures == 0)

            let copy = corruptSeparator(model, storage, at: 5)

            // BOTH pre-existing oracles are satisfied on this state — which
            // is exactly why the character check had to be added.
            #expect(model.index.documentLength == copy.length, "the totals still agree")
            #expect(EditorDocument.blockID(at: 5, in: copy) == nil,
                    "the boundary still carries no owner, so the attribute walk is clean")

            await withEditorAssertionsMuted { model.auditIdentityProjection() }
            #expect(model.identityAuditFailures == 1,
                    "the index's boundary no longer sits on a separator")
        }
    }

    /// The pre-existing hole, pinned: the walk used to `continue` past an
    /// EMPTY entry before reaching its separator check, so an empty block's
    /// boundary was never audited at all. RED ON THE PRE-FIX AUDIT for the
    /// second reason — not merely the missing character comparison, but the
    /// skipped iteration.
    @Test func anEmptyEntrysSeparatorIsAuditedToo() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["", "Beta"])
            let (model, storage) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(storage.string == "\nBeta")
            #expect(model.index.entries.map(\.length) == [0, 4])

            let copy = corruptSeparator(model, storage, at: 0)
            #expect(model.index.documentLength == copy.length)
            #expect(EditorDocument.blockID(at: 0, in: copy) == nil)

            await withEditorAssertionsMuted { model.auditIdentityProjection() }
            #expect(model.identityAuditFailures == 1,
                    "an empty block's boundary is audited like any other")
        }
    }

    // MARK: The false-positive guard (the half that matters most)

    /// **I4: internal newlines are CONTENT.** A block whose own text ends
    /// with a newline puts a `\n` at the offset just before its separator
    /// and another AT it — both legitimate. The check must stay silent
    /// through ordinary typing in such a document.
    @Test func aBlockWhoseTextEndsWithANewlineNeverFires() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Alpha\n", "Beta"])
            let (model, storage) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(storage.string == "Alpha\n\nBeta")
            #expect(model.index.entries.map(\.length) == [6, 4])

            // Type in both blocks — the audit runs per keystroke.
            typeEdit(model, storage, range: NSRange(location: 2, length: 0), replacement: "!")
            typeEdit(model, storage, range: NSRange(location: storage.length, length: 0),
                     replacement: "?")
            #expect(storage.string == "Al!pha\n\nBeta?")
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }

    /// A block that is nothing BUT newlines — the same rule taken to its
    /// edge (its whole range is separators-as-content).
    @Test func aBlockOfNothingButNewlinesNeverFires() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Alpha", "\n\n", "Beta"])
            let (model, storage) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(storage.string == "Alpha\n\n\n\nBeta")
            #expect(model.index.entries.map(\.length) == [5, 2, 4])
            typeEdit(model, storage, range: NSRange(location: 5, length: 0), replacement: "!")
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }

    /// Empty blocks — first, middle and last — typed into and around.
    @Test func emptyBlocksNeverFire() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["", "Beta", "", "Gamma", ""])
            let (model, storage) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(storage.string == "\nBeta\n\nGamma\n")
            #expect(model.index.entries.map(\.length) == [0, 4, 0, 5, 0])

            // Type INTO the leading empty block, then into a middle one.
            typeEdit(model, storage, range: NSRange(location: 0, length: 0), replacement: "A")
            typeEdit(model, storage, range: NSRange(location: 7, length: 0), replacement: "M")
            #expect(storage.string == "A\nBeta\nM\nGamma\n")
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }

    /// An empty block beside an OPEN TAIL — the last entry's separator is
    /// the tail's, and an empty last entry is where the skipped iteration
    /// and the tail rule meet.
    @Test func anEmptyLastBlockUnderAnOpenTailNeverFires() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Alpha", ""])
            let (model, storage) = makeEditor(session, postID: postID)
            await model.loadOnce()
            #expect(storage.string == "Alpha\n")

            typeAtEnd(model, storage, "\n")      // opens the tail
            typeAtEnd(model, storage, "delta")   // fills it
            #expect(storage.string == "Alpha\n\ndelta")
            #expect(model.index.tailLength == 5)
            #expect(model.index.documentLength == storage.length)
            #expect(model.identityAuditFailures == 0)
            #expect(model.desyncRecoveryCount == 0)
        }
    }
}

// MARK: - M13: the paste's bulk intent is discarded with its arming

@MainActor
@Suite("Mobile edit routing — a discarded arming takes its paste intent (round 2, M13)")
struct MobileBulkArmingTests {
    /// **M13** — a state batch 1's own binding created, and it closes
    /// where it was opened. `bulkPending` is armed at the gate BESIDE the
    /// verdict, off the same call (`.tail` + `isPaste`). When the binding
    /// later declines that arming, the verdict goes and the flag stayed —
    /// so the next crystallization ran as `.bulk` instead of `.typing`.
    ///
    /// The difference is visible in the store: `.typing` mints only
    /// COMPLETED paragraphs (a tail with no newline mints nothing), while
    /// `.bulk` segments the whole tail and closes the region. So a
    /// half-typed sentence becomes a block early — a one-shot wrong
    /// segmentation kind, no data loss, and exactly the kind of quiet
    /// wrongness the binding exists to stop.
    ///
    /// RED ON THE PRE-FIX TREE: "delta!" mints as a fourth block.
    @Test func aRejectedArmingClearsThePastesBulkIntent() async throws {
        try await withEditorWorld { session, db in
            let world = try await editRoutingFixture(session)
            let model = world.model
            let storage = world.storage

            // A PASTE is approved into the open tail: the verdict AND the
            // bulk-entry intent arm together.
            #expect(model.shouldChangeText(
                in: NSRange(location: 22, length: 5), replacement: "one\ntwo", isPaste: true))

            // …but what lands is a different edit entirely (the gate-less
            // system road), so the arming is declined.
            systemPathEdit(storage, range: NSRange(location: 8, length: 1), replacement: "")
            #expect(model.index.entries.map(\.length) == [5, 8, 5],
                    "the landing routed by fallback to its own block")

            // One ordinary keystroke in the tail now runs the
            // crystallization the flag would have mis-kinded.
            typeAtEnd(model, storage, "!")
            await model.awaitMintSettle()

            #expect(model.index.entries.count == 3,
                    "typing mints nothing: the tail holds no completed paragraph")
            #expect(model.index.tailLength == 6, "the tail is still open, holding 'delta!'")
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: world.postID)
                    == ["Alpha", "Bea beta", "Gamma"],
                    "the half-typed tail did not become a block")
        }
    }

    /// The other half, so the fix cannot be satisfied by never arming bulk
    /// at all: an arming that IS honored keeps its paste semantics.
    @Test func anHonoredPasteStillCrystallizesAsBulk() async throws {
        try await withEditorWorld { session, db in
            let world = try await editRoutingFixture(session)
            let model = world.model
            let storage = world.storage

            // The paste lands exactly as approved (gate, then the edit).
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: 22, length: 5), replacement: "one\ntwo",
                isPaste: true))
            await model.awaitMintSettle()

            #expect(model.index.tailLength == nil, "bulk entry closes the tail region")
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: world.postID)
                    == ["Alpha", "Beta beta", "Gamma", "one", "two"],
                    "the pasted paragraphs segmented on entry (AppSpec §7)")
        }
    }
}

// MARK: - M2e: the canary's idle tick is disarmed at teardown

@MainActor
@Suite("Mobile TK2 canary — the idle tick is torn down (round 2, M2e)")
struct MobileCanaryTeardownTests {
    /// RED ON THE PRE-FIX TREE: `disarmCanary()` had only test callers, so
    /// a 30-second repeating main-run-loop `Timer` accumulated per note
    /// ever opened, for the process's life.
    @Test func teardownDisarmsTheIdleTick() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "canary teardown", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha", at: .end)
            }
            let model = MobileEditorViewModel(
                session: session, postID: post.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            model.attach(textView: surface.textView)
            #expect(surface.textView.canaryIsArmed, "attach arms the idle tick")

            await model.teardown()
            // Otherwise: one orphaned repeating main-run-loop timer per
            // note ever opened, for the process's life.
            #expect(!surface.textView.canaryIsArmed, "the screen's teardown disarms it")
        }
    }

    /// **Round-2 ladder round 1, MINOR 3 — the ORDERING, which the pin
    /// above structurally cannot see.** It holds the surface strongly
    /// across `teardown()`'s await, so the disarm always lands whenever it
    /// runs. Production does not: `textView` is weak, `finish()` is a real
    /// DB round trip, and the only production caller is a NavigationStack
    /// pop, where SwiftUI releases the representable CONCURRENTLY — so a
    /// disarm sitting after the await silently did nothing whenever the
    /// view lost that race, which is exactly the accumulation M2e exists
    /// to close.
    ///
    /// The `afterDisarm` seam is what makes the ordering observable at all
    /// (the pre-fix ordering cannot be caught by racing it — a race that
    /// sometimes reproduces is not a pin). RED BY BEHAVIOURAL REVERT: move
    /// `textView?.disarmCanary()` back below `await finish()` and the
    /// observation reads `true`.
    @Test func theDisarmIsTeardownsFirstAct() async throws {
        try await withEditorWorld { session, _ in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "canary ordering", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Alpha", at: .end)
            }
            let model = MobileEditorViewModel(
                session: session, postID: post.id,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            model.attach(textView: surface.textView)
            #expect(surface.textView.canaryIsArmed)

            var armedAtFirstAwait: Bool?
            await model.teardown(afterDisarm: {
                armedAtFirstAwait = surface.textView.canaryIsArmed
            })
            #expect(armedAtFirstAwait == false,
                    "the tick is gone before teardown ever suspends")
        }
    }

    /// The other end of the same class: a canary that never reaches a
    /// teardown at all — a failed load, a cancelled push, or the pop above
    /// losing its race — still stops its tick. `Timer.scheduledTimer` hands
    /// ownership to the run loop, so an un-invalidated tick outlives every
    /// reference to it and keeps waking the main thread every 30 s for the
    /// process's life.
    ///
    /// RED ON THE PRE-FIX TREE (no `deinit`): the timer is still valid
    /// after its canary is gone. The pin holds the `Timer` itself, because
    /// once the canary deallocates there is nothing else left to ask.
    @Test func aCanaryThatDiesWithoutADisarmStillStopsItsTick() throws {
        let surface = MobileWriteSurfaceView()
        var canary: MobileFallbackCanary? = MobileFallbackCanary()
        canary?.arm(for: surface.textView)
        let timer = try #require(canary?.idleTimer, "the tick is scheduled")
        #expect(timer.isValid)

        canary = nil
        #expect(!timer.isValid, "the tick dies with its canary")
    }
}
