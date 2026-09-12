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
//  ── THE FLIP IS VIEW STATE, per note, defaulting to EDITED ───────────────
//  Her ruling says a click flips and a click returns; it does not make the
//  choice a remembered preference, and Apple Notes' own stamp reverts too.
//  So the flip is `@State` reset on the note (`.task(id:)`) — a glance
//  gesture, not a setting. Recorded in the batch record as the batch's call.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

struct MastheadStamp: View {
    let session: AppSession
    let postID: String
    let tokens: VoiceTokens
    /// "now", for the relative rule (the `SidebarNoteBox` convention).
    var now: Date = Date()

    @State private var stamps: Queries.NoteStamps?
    @State private var showsCreated = false

    private var subject: TimeStampFace.Subject { showsCreated ? .created : .edited }

    private var date: Date? {
        guard let stamps else { return nil }
        return showsCreated ? stamps.createdAt : stamps.editedAt
    }

    var body: some View {
        face
            .task(id: postID) {
                // A different note starts on its own edited stamp — the flip
                // is a glance at THIS note, never a mode the masthead is left
                // in.
                showsCreated = false
                stamps = nil
                await watch()
            }
            #if DEBUG
            // The four DEBUG oracles are this note's while its masthead
            // stands, and nobody's after (the ladder's R2-9). Without the
            // second line they grow one entry per note ever mounted — a
            // retained closure among them — and a pin that forgot to reset
            // could read an earlier mount's words as if they were this
            // note's.
            .onAppear { PostDetailOracle.flipStamp[postID] = { flip() } }
            .onDisappear { PostDetailOracle.resetStamp(postID) }
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
            Button {
                flip()
            } label: {
                Text(tokens.chromeLabel(words))
                    .font(tokens.small)
                    .lineLimit(1)
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .fixedSize()
            .help("\(TimeStampFace.tooltip(subject, date: date)) \u{2014} "
                  + "click to see when it was \(showsCreated ? "last edited" : "created")")
            .accessibilityLabel(words)
            .mastheadGeometryProbe(.stamp(postID), in: PostDetailView.mastheadSpace)
        } else {
            Color.clear.frame(width: 0, height: 0)
        }
    }

    private func flip() {
        showsCreated.toggle()
        #if DEBUG
        PostDetailOracle.stampShown[postID] = date.map {
            TimeStampFace.stamp(subject, date: $0, now: now)
        }
        #endif
    }

    private func watch() async {
        do {
            for try await read in session.database.observe({ [postID] db in
                try Queries.noteStamps(db, postID: postID)
            }) {
                stamps = read
                #if DEBUG
                PostDetailOracle.stampEditedAt[postID] = read?.editedAt
                PostDetailOracle.stampShown[postID] = date.map {
                    TimeStampFace.stamp(subject, date: $0, now: now)
                }
                #endif
            }
        } catch is CancellationError {
        } catch {
            // The last stamp stands; the chrome never blanks on a failed
            // read (the title's own posture, one row down).
        }
    }
}
