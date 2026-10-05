//
//  SupportMail.swift
//  Variorum (MAC ONLY)
//
//  Phase 13r U3-B — handing a `SupportDraft` to a mail app. The draft opens
//  ON SCREEN in the mail app, with everything it carries visible, and goes
//  only when she presses that app's own Send. Variorum sends nothing.
//
//  TWO ROADS, chosen by what the draft carries (external facts, gathered by
//  the unit's one lookup and recorded in the U3-B RECORD):
//   · NO ATTACHMENT (Help ▸ Send Feedback…) → a `mailto:` URL. It opens in
//     whichever mail app she has chosen as her default (Apple Mail, Outlook,
//     a web mail handler…).
//   · WITH THE REPORT ATTACHED (a crash report's Send) → AppKit's
//     compose-email sharing service, the one road that can attach a file
//     (Apple's QA1018: a `mailto:` cannot). It is effectively Apple Mail's.
//     When it cannot take the draft — or reports a failure that is not her
//     own cancel — the FALLBACK (PROVISIONAL, QUESTIONS #181): the same
//     draft as a `mailto:` naming the file, with the file shown in Finder so
//     she can attach it herself.
//   · If nothing opens at all, the door speaks a refusal (P-2).
//
//  MEASURED on the U3-B dev-store walk (macOS 27.0, Apple Mail with NO
//  account set up): `canPerform` answers TRUE, Mail opens its own Add
//  Account sheet instead of a draft, and the service reports SUCCESS
//  (`didShareItems`) — so the fallback above never runs there, and Variorum
//  cannot tell. Cancelling Mail's sheet quits Mail and the handed draft is
//  gone; nothing is sent. The plain `mailto:` road lands in the same sheet
//  when Mail is the default and has no account.
//
//  THE PRE-DRAFT CHOICE (19f — her QUESTIONS #181 (i) ruling, 2026-10-04):
//  so BEFORE ANY DRAFT OPENS, both doors ask — "Open in Mail" (the roads
//  above, exactly as they were) or the road that never needs a mail app:
//  the address onto the pasteboard and, for a report, its file shown in
//  Finder ("Show the file and copy the address"; feedback's "Copy the
//  address"). `SupportMail.ask` below is that question's one dispatcher;
//  the presenters are `SupportChoice.swift`'s.
//
//  The roads are injected (`SupportMailRoads`), so which road a draft takes
//  — and that nothing is ever sent — is pinned without opening a mail app.
//

import AppKit

/// The side effects a draft can take. Production: `LiveSupportMailRoads`.
@MainActor
protocol SupportMailRoads: AnyObject {
    /// Whether the compose-email service can take this draft as it is.
    func canCompose(_ draft: SupportDraft) -> Bool
    /// Opens the draft in the compose window. `onFailure` runs if the
    /// service later reports a failure that is not her own cancel.
    func compose(_ draft: SupportDraft, onFailure: @escaping @MainActor () -> Void)
    /// Opens a URL in its default handler; false if nothing took it.
    func open(_ url: URL) -> Bool
    /// Shows a file in Finder, selected.
    func reveal(_ url: URL)
}

@MainActor
enum SupportMail {
    enum Road: Equatable {
        case mailto
        case composeWithAttachment
        case mailtoAndReveal
        case nothingCouldOpen
    }

    /// Opens `draft` on screen in a mail app. `refuse` is the door's own
    /// refusal voice, used only when nothing could open (now or later).
    @discardableResult
    static func open(
        _ draft: SupportDraft,
        roads: SupportMailRoads = LiveSupportMailRoads.shared,
        refuse: @escaping @MainActor (String) -> Void
    ) -> Road {
        guard draft.attachment != nil else {
            if let url = draft.mailtoURL, roads.open(url) { return .mailto }
            refuse(SupportCopy.nothingCouldOpen)
            return .nothingCouldOpen
        }
        if roads.canCompose(draft) {
            roads.compose(draft) {
                _ = attachByHand(draft, roads: roads, refuse: refuse)
            }
            return .composeWithAttachment
        }
        return attachByHand(draft, roads: roads, refuse: refuse)
    }

    /// The fallback: the file shown in Finder, then the plain draft naming it.
    private static func attachByHand(
        _ draft: SupportDraft, roads: SupportMailRoads,
        refuse: @MainActor (String) -> Void
    ) -> Road {
        if let attachment = draft.attachment { roads.reveal(attachment) }
        if let url = draft.attachingByHand().mailtoURL, roads.open(url) { return .mailtoAndReveal }
        refuse(SupportCopy.nothingCouldOpen)
        return .nothingCouldOpen
    }

    // MARK: The pre-draft choice (19f — her #181 (i) ruling)

    /// What the door's question came to.
    enum Answer: Equatable {
        /// She closed the question: nothing opened, nothing was copied.
        case dismissed
        /// "Open in Mail" — the door's own road ran, and took this road.
        case openedInMail(Road)
        /// The second road: the address is on the pasteboard and, for a
        /// report, its file was shown in Finder. No draft opened.
        case copiedAddress(revealed: URL?)
    }

    /// **THE DOOR'S ONE QUESTION, asked BEFORE any draft opens.** Nothing
    /// opens, is copied or is shown until she answers.
    /// - `choose` puts the question on screen and returns her answer (nil =
    ///   dismissed) — a window's `.alert`, or with no window an app-modal
    ///   alert (`SupportChoice.swift`).
    /// - `openInMail` is the door's OWN mail road, run only on that answer —
    ///   exactly the road the door took before the choice existed.
    /// - The second road needs no mail app: `support@stargazing.tech` onto
    ///   `pasteboard` (cleared, then set — no expiry: it is a public address)
    ///   and the question's file, if any, shown in Finder through `roads`.
    @discardableResult
    static func ask(
        _ question: SupportQuestion,
        choose: SupportChooser,
        roads: SupportMailRoads = LiveSupportMailRoads.shared,
        pasteboard: NSPasteboard = .general,
        openInMail: @MainActor () -> Road
    ) async -> Answer {
        switch await choose(question) {
        case nil:
            return .dismissed
        case .openInMail:
            return .openedInMail(openInMail())
        case .copyAddress:
            pasteboard.clearContents()
            pasteboard.setString(SupportDraft.address, forType: .string)
            if let file = question.file { roads.reveal(file) }
            return .copiedAddress(revealed: question.file)
        }
    }
}

/// Her answer to the support doors' question (nil, where one is optional,
/// means she dismissed it).
nonisolated enum SupportChoice: Equatable, Sendable {
    /// "Open in Mail" — the draft roads, unchanged beneath the choice.
    case openInMail
    /// "Show the file and copy the address" / "Copy the address".
    case copyAddress
}

/// The question both support doors ask before any draft opens (19f). A
/// report's carries its file — the second road shows it in Finder;
/// feedback's carries none. The words are `SupportCopy`'s.
nonisolated struct SupportQuestion: Equatable, Sendable {
    let title: String
    let detail: String
    /// The first road's button.
    let openInMail: String
    /// The second road's button.
    let copyAddress: String
    /// The file the second road shows in Finder (a report's own), or nil.
    let file: URL?

    /// Help ▸ Send Feedback…: "Open in Mail" / "Copy the address".
    static let feedback = SupportQuestion(
        title: SupportCopy.feedbackChoiceTitle, detail: SupportCopy.feedbackChoiceDetail,
        openInMail: SupportCopy.openInMail, copyAddress: SupportCopy.copyAddress, file: nil)

    /// A crash report's Send Report…: "Open in Mail" / "Show the file and
    /// copy the address" — the file is the report's own, the very one the
    /// draft would attach.
    static func report(file: URL) -> SupportQuestion {
        SupportQuestion(
            title: SupportCopy.reportChoiceTitle, detail: SupportCopy.reportChoiceDetail,
            openInMail: SupportCopy.openInMail, copyAddress: SupportCopy.showFileAndCopyAddress,
            file: file)
    }
}

/// Puts a `SupportQuestion` on screen and returns her answer (nil =
/// dismissed). The presenters are `SupportChoice.swift`'s; a pin passes its
/// own.
typealias SupportChooser = @MainActor (SupportQuestion) async -> SupportChoice?

/// The real roads: AppKit's compose-email service, `NSWorkspace`.
@MainActor
final class LiveSupportMailRoads: NSObject, SupportMailRoads, NSSharingServiceDelegate {
    static let shared = LiveSupportMailRoads()

    /// Each in-flight draft's failure road, keyed by ITS OWN service
    /// instance (F5, ladder round 1 — the U3-B exchange's sharpening: a
    /// single slot not only DROPPED a road, it could run the WRONG draft's
    /// fallback — A fails late after B composes → B's file shown and named —
    /// and A's success nilled B's road). The value retains the service so
    /// the key's identity is stable for the callback's life; the entry
    /// leaves in either callback. (A service that never calls back would
    /// strand one entry on this app-long object — AppKit's compose service
    /// was measured to report every outcome, F-W5.)
    private var pendingFailureRoads:
        [ObjectIdentifier: (service: NSSharingService, road: @MainActor () -> Void)] = [:]

    private func items(_ draft: SupportDraft) -> [Any] {
        [draft.body as NSString] + (draft.attachment.map { [$0 as NSURL] } ?? [])
    }

    func canCompose(_ draft: SupportDraft) -> Bool {
        guard let service = NSSharingService(named: .composeEmail) else { return false }
        return service.canPerform(withItems: items(draft))
    }

    func compose(_ draft: SupportDraft, onFailure: @escaping @MainActor () -> Void) {
        guard let service = NSSharingService(named: .composeEmail) else {
            onFailure()
            return
        }
        service.recipients = [draft.recipient]
        service.subject = draft.subject
        expectFailureRoad(for: service, onFailure)
        service.perform(withItems: items(draft))
    }

    /// `compose`'s bookkeeping half, separable so the delegate contract is
    /// PINNABLE without `perform` (which would open Mail): the road is keyed
    /// by this service alone, and only this service's failure runs it.
    func expectFailureRoad(for service: NSSharingService, _ road: @escaping @MainActor () -> Void) {
        service.delegate = self
        pendingFailureRoads[ObjectIdentifier(service)] = (service, road)
    }

    func open(_ url: URL) -> Bool {
        NSWorkspace.shared.open(url)
    }

    func reveal(_ url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    // MARK: NSSharingServiceDelegate

    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
        pendingFailureRoads[ObjectIdentifier(sharingService)] = nil
    }

    func sharingService(
        _ sharingService: NSSharingService, didFailToShareItems items: [Any], error: any Error
    ) {
        let entry = pendingFailureRoads.removeValue(forKey: ObjectIdentifier(sharingService))
        // Her own cancel is an answer, not a failure: nothing more happens.
        if Self.isHerOwnCancel(error) { return }
        entry?.road()
    }

    /// A cancelled share (she closed the compose window unsent) is
    /// `NSUserCancelledError` in the Cocoa domain — her answer, never a
    /// reason to try another road.
    nonisolated static func isHerOwnCancel(_ error: any Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == NSCocoaErrorDomain && nsError.code == NSUserCancelledError
    }
}
