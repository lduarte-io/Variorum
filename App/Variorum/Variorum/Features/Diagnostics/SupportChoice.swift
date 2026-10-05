//
//  SupportChoice.swift
//  Variorum (MAC ONLY)
//
//  19f — THE PRE-DRAFT CHOICE ON SCREEN (her QUESTIONS #181 (i) ruling,
//  2026-10-04: "a small choice before the draft — 'Open in Mail' or 'Show
//  the file and copy the address'. The plain feedback door has the same
//  shape, minus the file."). Measured at 13r U3-B's walk (F-W5): on a Mac
//  whose Mail has no account, both doors landed in Mail's own Add Account
//  sheet with no draft, and Variorum could not tell. The second road never
//  needs a mail app, so the dead-end is closed by construction.
//
//  What lives here is only the PRESENTING. The question's words and the
//  roads it leads to are `SupportMail.swift`'s (`SupportQuestion`,
//  `SupportMail.ask`):
//   · `SupportChoiceAsk` — the channel a door asks through and a view
//     answers. It is `ShellRouter.ask`'s continuation shape (row 67), with
//     the same three rules: dismissal is an ANSWER (nil), never a silence;
//     a second ask answers the first rather than stranding it; answering and
//     clearing are one act, so a double press cannot resume twice.
//   · `.supportChoiceAlert(_:)` — the question as a SwiftUI `.alert`, the
//     grammar every confirm in the app uses. Settings ▸ Diagnostics hosts
//     one for Send Report…; every full window hosts the shell's
//     (`ShellRouter.supportChoice`) for Help ▸ Send Feedback….
//   · `SupportChoiceModal` — Help ▸ Send Feedback… is always enabled (it
//     needs no window or library), so with NO window to ask in (the library
//     not open, or every window closed) it asks through an app-modal alert,
//     the door's own no-window voice (it already speaks a refusal that way).
//     Its buttons are the same question's.
//

import AppKit
import Observation
import SwiftUI

/// The channel a support door asks through; a view presents `pending` and
/// answers it.
@MainActor
@Observable
final class SupportChoiceAsk {
    /// The question on screen, if any.
    private(set) var pending: Pending?

    struct Pending: Identifiable {
        let id = UUID()
        let question: SupportQuestion
        let answer: (SupportChoice?) -> Void
    }

    /// Ask, and wait for the view to answer. **A second ask answers the
    /// first with nil** — nothing may be left awaiting a question that is no
    /// longer on screen.
    func ask(_ question: SupportQuestion) async -> SupportChoice? {
        await withCheckedContinuation { continuation in
            pending?.answer(nil)
            pending = Pending(
                question: question,
                answer: { continuation.resume(returning: $0) })
        }
    }

    /// The view's side: answer and clear in one act.
    func answer(_ choice: SupportChoice?) {
        let asked = pending
        pending = nil
        asked?.answer(choice)
    }
}

extension View {
    /// Presents whatever `asking` holds: the two roads, then Cancel. A
    /// dismissal (Escape, Cancel) is the nil answer.
    func supportChoiceAlert(_ asking: SupportChoiceAsk) -> some View {
        alert(
            asking.pending?.question.title ?? "",
            isPresented: Binding(
                get: { asking.pending != nil },
                set: { shown in if !shown { asking.answer(nil) } }),
            presenting: asking.pending
        ) { pending in
            Button(pending.question.openInMail) { asking.answer(.openInMail) }
            Button(pending.question.copyAddress) { asking.answer(.copyAddress) }
            Button("Cancel", role: .cancel) { asking.answer(nil) }
        } message: { pending in
            Text(pending.question.detail)
        }
    }
}

/// The Help door's question when no window can ask it.
@MainActor
enum SupportChoiceModal {
    static func ask(_ question: SupportQuestion) -> SupportChoice? {
        let alert = NSAlert()
        alert.messageText = question.title
        alert.informativeText = question.detail
        alert.addButton(withTitle: question.openInMail)
        alert.addButton(withTitle: question.copyAddress)
        // Titled "Cancel", AppKit gives it the Escape key.
        alert.addButton(withTitle: "Cancel")
        switch alert.runModal() {
        case .alertFirstButtonReturn: return .openInMail
        case .alertSecondButtonReturn: return .copyAddress
        default: return nil
        }
    }
}
