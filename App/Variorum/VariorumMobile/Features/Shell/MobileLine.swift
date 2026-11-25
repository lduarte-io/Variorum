//
//  MobileLine.swift
//  VariorumMobile
//
//  **VM-61 — HOW A PHONE DOOR SPEAKS** (umbrella VM-55, batch 2a). The phone
//  has ONE message line, and it speaks through the ONE seam both platforms
//  share (`AppSession.status`, `Shared/StatusCenter.swift`). This file is the
//  phone doors' vocabulary over that seam: a door says what CLASS its message
//  is — decided where the message is produced, never guessed from the words —
//  and, for a removal, which existing road its Undo takes. It holds no rule of
//  what shows: that is the seam's one placement rule
//  (`StatusCenter.slot(kind:leavesPage:placement:receiptStyle:)`), which on the
//  phone is her VM-44 ruling — *"no line for ordinary acts; a short line with
//  Undo when something leaves the page, and for refusals."*
//
//  **Undo only over a road that already exists** (scope call 7): the note's
//  structural undo door (M20), Put back (the Trash's own ops), unarchive. A
//  removal whose Undo would need a new road carries none and is named in the
//  batch record with the umbrella that owns its act.
//
//  The per-screen slots the phone's models kept (`lastError`, `receipt`,
//  `status`, `statusMessage` …) stay as the models' own record of what they
//  last said — the pins read them, the Mac's AD-14 precedent ("view models
//  keep their `statusMessage` properties … the app-level PRESENTATION is this
//  center's") — but no screen draws them any more: the one line does.
//

import Foundation
import VariorumCore

@MainActor
enum MobileLine {
    /// What a message IS — the door's own answer.
    enum Class: Equatable {
        /// Nothing happened, and this says why. Always drawn, in the alarm.
        case refusal
        /// **A direction** — an outcome other than the one she asked for
        /// (P-55-7, P-55-11: a put back that landed elsewhere, "Already
        /// collected", an entry opened but not filed, a copy that could not
        /// follow the screen, a note made but not opened — A-260-1). Always
        /// drawn — the seam's `direct`, the refusal's class — and inked in the
        /// phone's muted, never the alarm (VM-265, P-55-19 → (b)).
        case direction
        /// An ordinary act landed. Her ruling: no line — the seam drops it on
        /// the phone (`StatusCenter.receipt`, the phone's placement).
        case ordinary
        /// Something left the page (a delete, a merge, an archive). Drawn,
        /// with its Undo when a road for it already exists.
        case removal(Undo?)
    }

    /// The roads a removal's Undo may take — each one already exists.
    enum Undo: Equatable {
        /// The note's structural undo door (M20 — `MobileUndoDoor.beginUndo`
        /// from the receipt surface, so A12's warning presents from the note's
        /// own host). The line is the note screen's: it is withdrawn as the
        /// screen goes (`withdrawNoteLine(of:)`), because the door dies with it.
        case structural
        /// Put back a note just moved to the Trash — the Trash's own Put back
        /// op for a note (`TrashPutBack`'s `.note` arm: `restoreContainer`).
        case putBackNote(String)
        /// Put back a book just moved to the Trash (`TrashPutBack`'s `.book`
        /// arm: `restoreReading`).
        case putBackBook(String)
        /// Unarchive a book just archived (`unarchiveReading`) — the daily
        /// Journal's Archive door is the phone's one book archive today.
        case unarchiveBook(String)
    }

    /// The Undo button's word — the phone's receipt Undo's own (M20).
    static let undoLabel = "Undo"

    /// Speaks `text` as `cls` through the session's one seam. A nil or blank
    /// message says nothing — except a removal carrying its Undo, which may
    /// speak with no words (the merge's and the cross-block join's shipped
    /// bare Undo; PROVISIONAL P-55-5). `door` is the note's structural undo
    /// door, required only by `.removal(.structural)`.
    static func say(
        _ text: String?, as cls: Class, session: AppSession, door: MobileUndoDoor? = nil
    ) {
        // **The note's Undo never outlives its moment** (M20's `didSet` law —
        // "a stale Undo button left standing beside a NEW sentence would offer
        // to reverse something the sentence does not name" — carried onto the
        // one line). A structural Undo names the stack's top AS IT WAS; any
        // later word from the same note — a refusal, a removal, an ordinary
        // act the line drops, a success clearing its slot, an undo from the ⋯
        // sheet — may have moved that top, so the note's own standing Undo
        // line is taken back first.
        if let door { withdrawNoteLine(of: door, session: session) }
        let words = text ?? ""
        switch cls {
        case .refusal:
            session.status.refuse(words)
        case .direction:
            session.status.direct(words)
        case .ordinary:
            session.status.receipt(words)
        case .removal(let undo):
            let resolved = undo.flatMap { action(for: $0, session: session, door: door) }
            session.status.removal(
                words, undo: resolved?.action, owner: resolved?.owner)
        }
    }

    /// The everyday case: a refusal (or nothing, for nil). The models whose
    /// error slot only ever holds a refusal speak through this from the
    /// slot's `didSet`.
    static func refuse(_ text: String?, session: AppSession) {
        guard let text else { return }
        say(text, as: .refusal, session: session)
    }

    /// **The note screen is going away** — its structural Undo goes with it,
    /// so a line still offering it is taken back. Anything else said since
    /// (a refusal, the delete's Put back line) stands.
    static func withdrawNoteLine(of door: MobileUndoDoor, session: AppSession) {
        session.status.withdraw(owner: ObjectIdentifier(door))
    }

    /// **VM-275 — her rule: a refusal raised in a note clears when she leaves
    /// that note** ("the error toast stays up even past leaving the note,
    /// which it shouldn't"). Only the CLEARING learns about navigation: the
    /// line stays one line (P-55-10) and fades on the seam's clock otherwise
    /// (P-55-3). The note screen calls this on its one leaving road (its
    /// `onDisappear` — Back, a swipe back, a screen pushed over it, and since
    /// VM-256 every page change), beside `withdrawNoteLine`, handing the id of
    /// the line that was showing when it arrived.
    static func leaveNote(session: AppSession, lineWhenShown: UUID?) {
        guard clearsOnLeavingNote(session.status.current, lineWhenShown: lineWhenShown)
        else { return }
        session.status.clear()
    }

    /// **The rule, pure.** What clears is a line of the refusal CLASS — a
    /// refusal, or a direction, which rides that class (PROVISIONAL C-275-1) —
    /// that was raised while the note showed: anything showing then that is not
    /// the line which stood when it arrived. A line from before the note opened
    /// is not the note's (the Today door's direction, said as its note is
    /// pushed); a removal is no refusal and keeps its Undo's clock (the note's
    /// delete pops the screen while its Put back line stands); an offer is a
    /// question, not the note's complaint.
    static func clearsOnLeavingNote(_ showing: StatusCenter.Item?, lineWhenShown: UUID?) -> Bool {
        guard let showing, showing.kind == .refusal else { return false }
        return showing.id != lineWhenShown
    }

    // MARK: - The roads

    private static func action(
        for undo: Undo, session: AppSession, door: MobileUndoDoor?
    ) -> (action: StatusCenter.Item.Action, owner: ObjectIdentifier?)? {
        switch undo {
        case .structural:
            guard let door else { return nil }
            return (StatusCenter.Item.Action(label: undoLabel, perform: {
                Task { await door.beginUndo(from: .receipt) }
            }), ObjectIdentifier(door))
        case .putBackNote(let id):
            return (StatusCenter.Item.Action(label: undoLabel, perform: {
                Task { await putBack(session: session, act: .putBack) { try $0.restoreContainer(id) } }
            }), nil)
        case .putBackBook(let id):
            return (StatusCenter.Item.Action(label: undoLabel, perform: {
                Task { await putBack(session: session, act: .putBack) { try $0.restoreReading(id) } }
            }), nil)
        case .unarchiveBook(let id):
            return (StatusCenter.Item.Action(label: undoLabel, perform: {
                Task { await unarchive(session: session) { _ = try $0.unarchiveReading(id) } }
            }), nil)
        }
    }

    /// Put back: the op, and — on a refusal — the deletion story's own
    /// put-back words. A landed Put back says nothing: the row is back on the
    /// page, and a restoration is an ordinary act (PROVISIONAL P-55-4).
    private static func putBack(
        session: AppSession, act: DeletionRefusal.Act,
        _ body: @escaping @Sendable (Operations) throws -> Void
    ) async {
        do {
            try await session.runner.run(body)
            NotificationCenter.default.post(name: .variorumPutBackLanded, object: session) // VM-64: the Library re-asks
        } catch {
            say(DeletionRefusal.sentence(error, act: act, roads: .phone), as: .refusal, session: session)
        }
    }

    /// Unarchive: the op, and the shared refusal table's words on a refusal
    /// (the archive door's own pairing — `MobileShelfViewModel`).
    private static func unarchive(
        session: AppSession, _ body: @escaping @Sendable (Operations) throws -> Void
    ) async {
        do {
            try await session.runner.run(body)
        } catch {
            say(
                OpsRefusalCopy.words(for: error, roads: .phone)
                    ?? DeletionRefusal.sentence(error, act: .putBack, roads: .phone),
                as: .refusal, session: session)
        }
    }
}
