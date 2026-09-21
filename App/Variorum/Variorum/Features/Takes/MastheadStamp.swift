//
//  MastheadStamp.swift
//  Variorum (Mac)
//
//  **18h batch 1 — the note's own time** (the 2026-09-12 use-report round,
//  her ledger row 9; ruling R-Q7). Her words: *"I need to be able to see the
//  created time and last edited time easily on the library and within the
//  note itself… I like how apple notes does it where you can see the time it
//  was last edited and if you click on it you see when it was created."*
//
//  A quiet stamp at the TRAILING end of the masthead's second row — the "in
//  no book" row — saying *edited today 1:33 AM*, flipping to *created …* on
//  a click and back on the next. The words are `TimeStampFace`'s, the same
//  brain the Library's rows and 18d's facts line read.
//
//  ── WHY A HELD READ, NOT A ONE-SHOT (17o rows 18/19's lesson) ────────────
//  The whole point of an "edited" stamp is that it MOVES while she types.
//  The masthead's title learned this the hard way: a `.task(id: postID)`
//  one-shot left the words standing while the store moved underneath, and
//  the fix — row 19 — was the same read, HELD. So this is a
//  `ValueObservation` on the note's own stamps, `removeDuplicates` keeping
//  the view still while nothing shown has changed.
//
//  The cost is honest and bounded: `Queries.noteStamps` reads the container
//  row and a MAX over the note's savepoints — this note's own rows, never
//  the corpus (P1). It re-runs when `container`/`commit_point`/`variant`
//  move, which is autosave's own rate; the observation's own equality gate
//  is what keeps a keystroke from redrawing chrome (the same shape the
//  title's held read already runs at).
//
//  ── THE CLICK CYCLES THREE FACES, AND THE CHOICE IS REMEMBERED ───────────
//  **13u4 UNIT S2 — her item 1** (2026-09-19), verbatim: *"clicking on
//  edited date goes to created, then collapses to a little clock icon.
//  remembers this on every note, so if you're normally in clock mode a new
//  note would open with only a clock icon… I don't necessarily want an
//  appearance setting - I want these to be changed by clicking on them."*
//
//  This SUPERSEDES 18h's own recorded call — *"the flip is `@State` reset on
//  the note … a glance gesture, not a setting"* — in both halves: there is a
//  THIRD face, and the choice is REMEMBERED rather than reset per note. The
//  memory is what her second sentence asks for; the click is what her last
//  sentence forbids Settings from doing.
//
//  Nothing about the WORDS changed: every face says exactly what
//  `TimeStampFace` says, the one brain, and the collapsed face says it on
//  hover instead of on the row.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

/// **The masthead stamp's resting face** — her three, in her order.
///
/// Pure and at file scope, so the cycle is a rule a pin holds rather than a
/// `toggle()` buried in a view body (F-0), and so the app has ONE answer to
/// "which stamp is the masthead showing".
nonisolated enum StampFace: String, CaseIterable, Sendable {
    /// `edited today 1:33 PM` — the shipped resting face, and the default.
    case edited
    /// `created Sep 1` — her first click.
    case created
    /// The collapsed face: *"a little clock icon"*. The words are not lost,
    /// they move to the hover — which is the whole idea of a collapse.
    case clock

    /// Her cycle: *"clicking on edited date goes to created, then collapses
    /// to a little clock icon"* — and a click again brings the date back.
    var next: StampFace {
        switch self {
        case .edited: .created
        case .created: .clock
        case .clock: .edited
        }
    }

    /// Which stamp this face is ABOUT. The collapsed face is still the
    /// EDITED stamp — the note's own "when did I last touch this", which is
    /// what the masthead rests on — so the clock's tooltip says that fact
    /// rather than the one she cycled past.
    var subject: TimeStampFace.Subject {
        self == .created ? .created : .edited
    }

    /// Whether the face draws the words at all.
    var showsWords: Bool { self != .clock }

    /// **LOCAL to this Mac, and GLOBAL to every note** — her sentence's own
    /// reading: *"remembers this on every note, so if you're normally in
    /// clock mode a new note would open with only a clock icon"* reads most
    /// naturally as one choice governing every note, not a row per note.
    /// (The per-note alternative is recorded as the PROVISIONAL, QUESTIONS
    /// #132.) Never synced: the `appearanceChoice` / `readModeOutlineShown`
    /// / `libraryCatalogSort` class — how she likes a stamp to look is this
    /// machine's taste, not document semantics. Zero schema, zero `setting`
    /// key, the lockstep marker stays 8.
    ///
    /// **Its defaults family** (`KnownIssuesAndTechDebt` rows 42/43, which
    /// the brief asks every new key to name): it is NOT a per-note key, so
    /// row 43's outlives-the-note family does not apply — there is one value
    /// for the app and nothing to evict when a note dies. It DOES share row
    /// 42's harness hazard, because the test host IS
    /// `io.lduarte.Variorum.debug` and a suite writing `.standard` writes
    /// the dev-store app's own domain. The seam for that is SwiftUI's own
    /// and needs no plumbing: every pin mounts under
    /// `.defaultAppStorage(<a scrubbed suite>)`, so no pin can read what a
    /// walk left behind, nor leave anything behind for one.
    static let key = "mastheadStampFace"

    /// A stored value that is not one of the three reads as `.edited` — the
    /// posture `AppearanceChoice.remembered` and `LibraryCatalogModel`'s
    /// sort take with their own local keys.
    static func remembered(_ defaults: UserDefaults = .standard) -> StampFace {
        defaults.string(forKey: key).flatMap(StampFace.init(rawValue:)) ?? .edited
    }
}

struct MastheadStamp: View {
    let session: AppSession
    let postID: String
    let tokens: VoiceTokens
    /// "now", for the relative rule (the `SidebarNoteBox` convention).
    var now: Date = Date()

    @State private var stamps: Queries.NoteStamps?
    /// **Her remembered choice** (item 1) — one face for every note, local
    /// to this Mac, written by the click and by nothing else. `@AppStorage`
    /// rather than a read at mount, so a click in one note window moves
    /// every other masthead in the process at once: one choice means one
    /// choice everywhere, which is what "normally in clock mode" means.
    @AppStorage(StampFace.key) private var restingFace: StampFace = .edited
    #if DEBUG
    /// **This masthead's own name in the DEBUG oracle** (13u4 UNIT S2 —
    /// row 51's two-window edge). `@State`, so it is minted once per view
    /// identity and survives every body re-evaluation; DEBUG-only, so the
    /// shipping build carries neither the field nor the mint.
    @State private var oracleOwner = UUID()
    #endif

    private var subject: TimeStampFace.Subject { restingFace.subject }

    private var date: Date? {
        guard let stamps else { return nil }
        return restingFace.subject == .created ? stamps.createdAt : stamps.editedAt
    }

    var body: some View {
        face
            .task(id: postID) {
                // A different note arrives in the face she LEFT THE APP IN —
                // her item 1: *"remembers this on every note, so if you're
                // normally in clock mode a new note would open with only a
                // clock icon."* (18h reset it here, deliberately, on the
                // reading that the flip was a glance; her ruling supersedes
                // that, and the reset is what had to go.)
                stamps = nil
                #if DEBUG
                // The flip door is registered HERE (the 17q ladder's R1-5):
                // `task(id:)` runs on a fresh mount AND on every swap, so the
                // new note's door exists after `onChange(of: postID)` has
                // cleared the old note's — `onAppear` alone never re-fired on
                // a swap. Synchronous, before the await, so it is as prompt.
                PostDetailOracle.claimStamp(postID, owner: oracleOwner) { flip() }
                #endif
                await watch()
            }
            #if DEBUG
            // The four DEBUG oracles are this note's while its masthead
            // stands, and nobody's after (the ladder's R2-9). Without a
            // teardown they grow one entry per note ever mounted — a
            // retained closure among them — and a pin that forgot to reset
            // could read an earlier mount's words as if they were this
            // note's.
            //
            // **The PER-NOTE boundary is the swap, not the disappearance**
            // (the ladder's R3-10): a `.task(id: postID)` swap — the view
            // staying, the note changing — runs no `onDisappear`, so the
            // PREVIOUS note's three entries and its `stampFrames` row
            // survived it. They are cleared here, where the old id is still
            // in hand.
            //
            // **…and it takes ITS OWN entry, never the note's row** (13u4
            // UNIT S2 — row 51's first edge): with the SAME note open in two
            // windows, a wholesale reset here emptied the other masthead's
            // entries while it was still drawn. Measured red before the fix
            // (`StampOracleOwnershipTests`).
            .onChange(of: postID) { old, _ in
                PostDetailOracle.releaseStamp(
                    old, owner: oracleOwner, in: session.debugProbeScope)
            }
            .onDisappear {
                PostDetailOracle.releaseStamp(
                    postID, owner: oracleOwner, in: session.debugProbeScope)
            }
            #endif
    }

    /// **Always a real view, even before the stamps land.** A branch that
    /// renders `EmptyView` contributes NO subview to `MastheadRowTwo`'s
    /// layout — and a view that is not in the tree never runs its `.task`,
    /// so the read that would fill the words could never start: the stamp
    /// would be empty forever. The waiting face is therefore a zero-size
    /// `Color.clear`, which row two sizes at 0 and treats exactly as "no
    /// stamp" (the two-subview arithmetic, unchanged).
    @ViewBuilder private var face: some View {
        if let date {
            let words = TimeStampFace.stamp(subject, date: date, now: now)
            // 13u4 UNIT S2 (row 51): the button, its style, its `fixedSize`
            // and the em-dashed tooltip grammar are `FlippingStamp`'s now —
            // the ONE flipping stamp, shared with the Library card's. The
            // words, the subject and the probe stay this masthead's.
            FlippingStamp(
                tokens: tokens,
                help: "\(TimeStampFace.tooltip(subject, date: date)) \u{2014} \(hint)",
                flip: flip
            ) {
                if restingFace.showsWords {
                    Text(tokens.chromeLabel(words))
                        .font(tokens.small)
                        .lineLimit(1)
                } else {
                    // **The collapsed face** (item 1): the glyph inside a
                    // `Text`, so it carries the row's own text baseline —
                    // a bare `Image` hands the stack its bottom edge
                    // (`CatalogBookLine`'s measured note, one file over) and
                    // `MastheadRowTwo` aligns row two on the first baseline.
                    Text(Image(systemName: "clock"))
                        .font(tokens.small)
                        .lineLimit(1)
                }
            }
            // The words are never lost behind the icon: they are the
            // tooltip's first half, and they are what a screen reader is
            // told the control IS.
            .accessibilityLabel(words)
            .mastheadGeometryProbe(.stamp(postID), in: PostDetailView.mastheadSpace)
        } else {
            Color.clear.frame(width: 0, height: 0)
        }
    }

    /// What a click will do NEXT, in the shared vocabulary — the third
    /// state is the masthead's own, so its two clauses live beside
    /// `toSee`'s table rather than in this body.
    private var hint: String {
        switch restingFace {
        case .edited: StampFlipHint.toSee(.created)
        case .created: StampFlipHint.toCollapse
        case .clock: StampFlipHint.toShowTheDate
        }
    }

    private func flip() {
        restingFace = restingFace.next
        #if DEBUG
        reportShown()
        #endif
    }

    #if DEBUG
    private func reportShown() {
        PostDetailOracle.recordStamp(
            postID,
            // The collapsed face says nothing on the row, so it reports
            // nothing — and the FACE beside it is how a pin tells that from
            // a read that has not landed.
            words: restingFace.showsWords
                ? date.map { TimeStampFace.stamp(subject, date: $0, now: now) } : nil,
            owner: oracleOwner)
        PostDetailOracle.recordStampFace(
            postID, face: restingFace.rawValue, owner: oracleOwner)
    }
    #endif

    private func watch() async {
        do {
            for try await read in session.database.observe({ [postID] db in
                try Queries.noteStamps(db, postID: postID)
            }) {
                stamps = read
                #if DEBUG
                PostDetailOracle.recordStampEdited(
                    postID, at: read?.editedAt, owner: oracleOwner)
                reportShown()
                #endif
            }
        } catch is CancellationError {
        } catch {
            // The last stamp stands; the chrome never blanks on a failed
            // read (the title's own posture, one row down).
        }
    }
}
