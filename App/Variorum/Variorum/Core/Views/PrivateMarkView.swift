//
//  PrivateMarkView.swift
//  Variorum (MAC ONLY) — Core/Views (the shared home: every host of the ONE
//  shared icon renders it — the Library's note and book rows, the Timeline,
//  the Pool, the Bookcase rows, the Book Panel and the note's masthead)
//
//  VX-831 — THE VISIBLE PRIVATE MARK, the shared-with-AI icon's deliberate
//  counterpart. Her ask (2026-11-04): "the deeper problem is that things that
//  are private do not carry a visible mark of being private. i like the
//  'shared with AI' symbol, but we need a deliberate private symbol too."
//
//  THE RULED FACTS (the ticket; the VX-878 record's BATCH 2 BRIEF):
//  - the glyph is option A, THE CLOSED EYE WITH LASHES — monochrome, in the
//    shared icon's line family. No SF Symbol draws a closed eye with lashes
//    (the catalogue's eye family is eye · eye.slash · eye.half.closed ·
//    eyes), so it is drawn here (`ClosedEyeGlyph`) — PROVISIONAL D-831-1;
//  - shown wherever the shared icon shows, on note rows, book rows, the note's
//    masthead and the Book Panel — never a gathering (gatherings refuse the
//    mark), never a wing (not markable);
//  - it joins the badge family's one switch (`ownership_badges`);
//  - a note private VIA ITS BOOK wears it at FULL strength — no muting — with
//    the hover saying why ("Private — via ‹book›", the VX-426 family);
//  - THE MARK IS A DOOR: its OWN mark clicked un-privates (the op her Private
//    row runs, no confirm — every Private toggle has none, D-831 rail (a));
//    private VIA ITS BOOK cannot be un-privated in place, and the click says
//    so, naming the book, with one door that opens it at the note (rail (b),
//    D-831-2);
//  - it reads the STORE's own fact, independent of client state (N-2), and
//    only for the rows a host DRAWS (P1 — the shared icon's law, bound
//    identically: `Queries.privateMarks` / `privateBookMarks`, held by
//    `PrivateMarkHold` over the drawn ids).
//
//  Pieces (P-9): the RULE (`PrivateMarkFace` — pure), the WORDS
//  (`PrivateMarkCopy`, in PrivateMark.swift beside the row's), the ACT
//  (`PrivateMarkAct`), the HOLD (`PrivateMarkHold`), the FACE
//  (`PrivateMarkView` over `ClosedEyeGlyph`).
//

import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

// MARK: - The rule (which mark a row wears, and what its press does)

nonisolated enum PrivateMarkFace {
    enum Mark: Equatable, Sendable {
        /// The note's OWN mark — `alsoVia` names any Private book that would
        /// still hold it private once the own mark is gone.
        case ownNote(alsoVia: [Queries.BookRef])
        /// Private only through these live Private books (full strength).
        case viaBooks([Queries.BookRef])
        /// A book's own mark.
        case ownBook
    }

    /// What a press on the mark does.
    enum Press: Equatable, Sendable {
        /// `setNotePrivate(id, false)` — `stillVia` shapes the receipt.
        case unmarkNote(stillVia: [Queries.BookRef])
        /// `setBookPrivate(id, false)`.
        case unmarkBook
        /// Nothing can act here: say so, naming the books, with a door to the
        /// first one.
        case sayVia([Queries.BookRef])
    }

    /// **A note row's mark** — the fact, under the badge family's switch.
    static func note(_ fact: Queries.PrivateMark?, badgesOn: Bool) -> Mark? {
        guard badgesOn, let fact, fact.isPrivate else { return nil }
        return fact.own ? .ownNote(alsoVia: fact.viaBooks) : .viaBooks(fact.viaBooks)
    }

    /// **A book row's mark** — its own stamp (the facts never name a
    /// gathering), under the switch.
    static func book(marked: Bool, badgesOn: Bool) -> Mark? {
        badgesOn && marked ? .ownBook : nil
    }

    // (The note's masthead — the in-note indicator — reads `note(_:badgesOn:)`
    // exactly as a row does: ONE switch governs the mark everywhere, the
    // ruling's letter, so the switch's own "Off: no marks anywhere" stays
    // true. The lock the mark replaced showed whenever the indicator did;
    // with badges off that sign is now gone too — PROVISIONAL D-831-3.)

    /// The hover, and the accessibility label.
    static func help(_ mark: Mark) -> String {
        switch mark {
        case .ownNote(let via) where via.isEmpty: PrivateMarkCopy.markOwnNoteHelp
        case .ownNote(let via): PrivateMarkCopy.markOwnNoteAlsoViaHelp(via.map(\.name))
        case .viaBooks(let books): PrivateMarkCopy.markViaHelp(books.map(\.name))
        case .ownBook: PrivateMarkCopy.markOwnBookHelp
        }
    }

    static func press(_ mark: Mark) -> Press {
        switch mark {
        case .ownNote(let via): .unmarkNote(stillVia: via)
        case .viaBooks(let books): .sayVia(books)
        case .ownBook: .unmarkBook
        }
    }
}

// MARK: - The act (the press, through the existing operations)

@MainActor
enum PrivateMarkAct {
    /// **The press.** The own arms run the very ops her Private rows run
    /// (`setNotePrivate` / `setBookPrivate`, through the runner — P2), with
    /// the rows' receipts; a refusal is the op's own. The via-book arm acts
    /// on nothing: it SAYS so, with one door — the owned-by badge's
    /// click-through (`MembershipChip.ascend`), the book opened at the note.
    /// A line carrying a door is an OFFER on the seam (it toasts exactly as a
    /// refusal does). Nothing here writes `ai_private_at` but her press.
    static func perform(
        _ press: PrivateMarkFace.Press, subjectID: String, subjectName: String?, session: AppSession
    ) async {
        switch press {
        case .unmarkNote(let stillVia):
            do {
                let wrote = try await session.runner.run { try $0.setNotePrivate(subjectID, false) }
                if wrote {
                    session.status.receipt(stillVia.isEmpty
                        ? PrivateMarkCopy.clearedNote
                        : PrivateMarkCopy.clearedNoteStillVia(stillVia.map(\.name)))
                }
            } catch {
                session.status.refuse(OpsRefusalCopy.message(for: error))
            }
        case .unmarkBook:
            do {
                let wrote = try await session.runner.run { try $0.setBookPrivate(subjectID, false) }
                if wrote { session.status.receipt(PrivateMarkCopy.clearedBook(subjectName ?? "This book")) }
            } catch {
                session.status.refuse(OpsRefusalCopy.message(for: error))
            }
        case .sayVia(let books):
            let words = PrivateMarkCopy.viaBookSaying(books.map(\.name))
            guard let first = books.first else {
                session.status.refuse(words)
                return
            }
            session.status.offer(
                words,
                action: .init(label: PrivateMarkCopy.openBookDoor(first.name)) {
                    MembershipChip.ascend(bookID: first.id, postID: subjectID)
                })
        }
    }
}

// MARK: - The hold (the drawn ids' facts, observed)

@MainActor
enum PrivateMarkHold {
    /// Hold the marks of the NOTES a host draws until the calling task is
    /// cancelled (a host's `.task(id:)` restarting on new rows, or its view
    /// leaving), landing each distinct answer. ∝ the ids — the owned-by badge
    /// facts' page-driven posture. A failed read lands nothing (silence,
    /// never a wrong mark).
    static func notes(
        _ session: AppSession, _ ids: [String],
        land: @escaping @MainActor ([String: Queries.PrivateMark]) -> Void
    ) async {
        guard !ids.isEmpty else {
            land([:])
            return
        }
        do {
            for try await value in session.database.observe({ try Queries.privateMarks($0, noteIDs: ids) }) {
                guard !Task.isCancelled else { return }
                land(value)
            }
        } catch {}
    }

    /// The BOOKS' twin (reads `reading` only — never at autosave rate).
    static func books(
        _ session: AppSession, _ ids: [String], land: @escaping @MainActor (Set<String>) -> Void
    ) async {
        guard !ids.isEmpty else {
            land([])
            return
        }
        do {
            for try await value in session.database.observe({ try Queries.privateBookMarks($0, readingIDs: ids) }) {
                guard !Task.isCancelled else { return }
                land(value)
            }
        } catch {}
    }
}

// MARK: - The face

/// Everything one drawn mark needs: what it is, whose it is, and the road.
struct PrivateMarkDoor {
    let mark: PrivateMarkFace.Mark
    /// The note's or book's id.
    let subjectID: String
    /// A book's name, for its receipt (nil on a note).
    var subjectName: String? = nil
    let session: AppSession
}

/// **The mark.** The calm state is NO view (the shared icon's rule): a host
/// writes it once, unguarded, and a row that is not Private measures exactly
/// what it did.
struct PrivateMarkView: View {
    /// P-1's walk: a note's mark is `.markNotePrivate`'s `.surface` door (the
    /// own arm) and the via-book arm's door is the ascent (`.openBookAtNote`,
    /// the owned-by badge's); a book's mark is `.markBookPrivate`'s.
    static let noteSurfaceCapabilities: [CapabilityID] = [.markNotePrivate, .openBookAtNote]
    static let bookSurfaceCapabilities: [CapabilityID] = [.markBookPrivate]

    /// The drawn size — the shared icon's footprint at row size (its glyph is
    /// drawn a size up and semibold, W-UX-7), a closed eye being wide and low.
    static let glyphSize = CGSize(width: 16, height: 7.5)

    let door: PrivateMarkDoor?
    let tokens: VoiceTokens

    var body: some View {
        if let door {
            let help = PrivateMarkFace.help(door.mark)
            Button {
                Task {
                    await PrivateMarkAct.perform(
                        PrivateMarkFace.press(door.mark), subjectID: door.subjectID,
                        subjectName: door.subjectName, session: door.session)
                }
            } label: {
                ClosedEyeGlyph()
                    .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(tokens.ink)
                    .frame(width: Self.glyphSize.width, height: Self.glyphSize.height)
                    .padding(.horizontal, 2)
                    .padding(.vertical, 3)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            // The lashes' tips rest on the row's text baseline.
            .alignmentGuide(.firstTextBaseline) { $0[.bottom] - 3 }
            .help(help)
            .accessibilityLabel(help)
            .privateMarkProbe(door)
        }
    }
}

/// **The closed eye with lashes** (option A, hers): the shut lid as a low
/// downward bow, four short lashes falling from it, drawn as one stroked
/// line glyph (round caps — the outline family the shared icon wears). Drawn
/// in a 20 × 9 design box scaled to the frame.
nonisolated struct ClosedEyeGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 20
        let sy = rect.height / 9
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }
        // The lid: a quadratic bow from (1, 1) to (19, 1), lowest at y = 5.
        let start = (x: CGFloat(1), y: CGFloat(1))
        let control = (x: CGFloat(10), y: CGFloat(9))
        let end = (x: CGFloat(19), y: CGFloat(1))
        var path = Path()
        path.move(to: p(start.x, start.y))
        path.addQuadCurve(to: p(end.x, end.y), control: p(control.x, control.y))
        // Four lashes, each along the bow's outward (downward) normal.
        for t in [0.2, 0.4, 0.6, 0.8] as [CGFloat] {
            let u = 1 - t
            let x = u * u * start.x + 2 * u * t * control.x + t * t * end.x
            let y = u * u * start.y + 2 * u * t * control.y + t * t * end.y
            let dx = 2 * u * (control.x - start.x) + 2 * t * (end.x - control.x)
            let dy = 2 * u * (control.y - start.y) + 2 * t * (end.y - control.y)
            let length = (dx * dx + dy * dy).squareRoot()
            // The normal pointing down-and-out of the bow (positive y).
            var nx = -dy / length
            var ny = dx / length
            if ny < 0 { nx = -nx; ny = -ny }
            path.move(to: p(x, y))
            path.addLine(to: p(x + nx * 3, y + ny * 3))
        }
        return path
    }
}

#if DEBUG
/// **WHICH MARK EACH SUBJECT DREW, AS A TEST ORACLE** (the
/// `OwnershipBadgeProbe` pattern): recorded on appear, cleared on disappear —
/// an absent subject is an honest "no mark drawn". DEBUG only.
@MainActor
enum PrivateMarkProbe {
    static var drawn: [String: PrivateMarkFace.Mark] = [:]
    static func reset() { drawn = [:] }
}
#endif

extension View {
    @ViewBuilder
    fileprivate func privateMarkProbe(_ door: PrivateMarkDoor) -> some View {
        #if DEBUG
        let id = door.subjectID
        let mark = door.mark
        onAppear { PrivateMarkProbe.drawn[id] = mark }
            .onChange(of: mark) { _, now in PrivateMarkProbe.drawn[id] = now }
            .onDisappear { if PrivateMarkProbe.drawn[id] == mark { PrivateMarkProbe.drawn[id] = nil } }
        #else
        self
        #endif
    }
}
