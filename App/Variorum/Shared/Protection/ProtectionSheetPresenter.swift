//
//  ProtectionSheetPresenter.swift
//  Variorum (shared: Mac + Mobile — the phone's Protection screen presents through it on its `.settings` host, VM-8)
//
//  VX-308 U1 piece 2 — THE ONE PRESENTER for the new road's protection sheets (VX-239 + VX-243's rule, carried onto the
//  new road; `notes/plans/vx-308-accounts-key-doors.md` §5a, the U1 ARBITRATION's R-6). OWNED BY THE BOOTSTRAP beside the
//  crossings' and the account's models, so it outlives the reopen a crossing makes:
//
//    - ONE SHEET AT A TIME: a second door's press while a sheet stands presents nothing (the standing sheet keeps the
//      floor); a sheet may hand the floor to its successor in place (`replace` — the signed-out road's *Continue* hands
//      it to Use Castle's confirm).
//    - ONLY ITS HOST PRESENTS IT (VX-243 — "the follow sheet presents on two windows at once"): a sheet is presented ON a
//      host scene (Settings ▸ Protection on the Mac), and `sheet(for:)` answers it to that host alone; any other host
//      presents nothing, so no two windows ever show one sheet.
//    - KEPT ACROSS ITS OWN ACT'S REOPEN (a crossing closes and reopens the library under its confirm — the `.ready` tree,
//      the Settings pane and its `@State` go down and come back; the sheet, held here, comes back with them), and DROPPED
//      AT EVERY SETTLED CLOSED STATE (VX-239 — "a pane-hosted ceremony sitting idle across lock/unlock comes back hidden"):
//      the bootstrap calls `libraryClosed()` whenever an open settles anywhere but ready — the lobby, the interlude, the
//      missing face, a failure — so a sheet never re-presents after an unlock. An act still running under a dropped sheet
//      finishes on its own road; its sheet is simply gone.
//
//  Today's road's own presenters (the controller's ceremony and follow) and their two bugs were retired with it at VX-329
//  U1; this is the one presenter.
//

import Foundation
import Observation
import VariorumCore

/// A scene that presents protection sheets. On the Mac, Settings ▸ Protection is THE host (`settings`); a pin names its
/// own to prove a second host presents nothing.
nonisolated struct ProtectionSheetHost: Hashable, Sendable {
    let scene: String

    static let settings = ProtectionSheetHost(scene: "settings")
}

/// The Account sheet asked for from a protection face (*Sign in…* — R-5): the platform's face composes the app's one
/// sign-in surface; `closed` runs when it goes (the section re-reads).
@MainActor
final class ProtectionSignInRequest: Identifiable {
    let id = UUID()
    let closed: () -> Void

    init(closed: @escaping () -> Void) {
        self.closed = closed
    }
}

/// The one presenter.
@MainActor
@Observable
final class ProtectionSheetPresenter {
    enum Sheet: Identifiable {
        /// A crossing's confirm (Use Castle, Use Standard, Replace All Keys — VX-307 U2a).
        case crossing(RoadCrossingConfirmModel)
        /// Use Castle while signed out — the signed-out screen (Continue: This Mac Only, then Use Castle's confirm).
        case signedOutCastle(RoadSignedOutCastleModel)
        /// An account door's confirm (turning sync on, the three local leaves).
        case account(RoadAccountConfirmModel)
        /// Sign out — today's shipped confirm.
        case signOut(RoadSignOutModel)
        /// The Account sheet (sign in).
        case signIn(ProtectionSignInRequest)
        /// VX-308 U3 — a key door's confirm (Change passphrase, Reset forgotten passphrase).
        case keyDoor(RoadKeyDoorConfirmModel)
        /// VX-510 D-B7 — VX-513, the read-only check ("Check my passphrase or twelve words…").
        case checkSecrets(RoadSecretCheckModel)

        var id: UUID {
            switch self {
            case .crossing(let model): return model.id
            case .signedOutCastle(let model): return model.id
            case .account(let model): return model.id
            case .signOut(let model): return model.id
            case .signIn(let request): return request.id
            case .keyDoor(let model): return model.id
            case .checkSecrets(let model): return model.id
            }
        }

        /// Her way out of the sheet — the model's own Cancel (a running act keeps its sheet; a check reads only, so its
        /// sheet always goes).
        func cancel() {
            switch self {
            case .crossing(let model): model.cancel()
            case .signedOutCastle(let model): model.cancel()
            case .account(let model): model.cancel()
            case .signOut(let model): model.cancel()
            case .signIn: break
            case .keyDoor(let model): model.cancel()
            case .checkSecrets(let model): model.cancel()
            }
        }
    }

    /// The standing sheet (nil: none).
    private(set) var sheet: Sheet?
    /// The host it is presented on.
    private(set) var host: ProtectionSheetHost?

    /// Presents `sheet` on `host` — false (nothing presented) while another sheet stands: one at a time.
    @discardableResult
    func present(_ sheet: Sheet, on host: ProtectionSheetHost) -> Bool {
        guard self.sheet == nil else { return false }
        self.sheet = sheet
        self.host = host
        return true
    }

    /// The standing sheet `id` hands the floor to `successor`, on the same host — false when `id` no longer stands.
    @discardableResult
    func replace(_ id: UUID, with successor: Sheet) -> Bool {
        guard sheet?.id == id else { return false }
        sheet = successor
        return true
    }

    /// What `host` presents now — the standing sheet on ITS host only (VX-243: never two windows).
    func sheet(for host: ProtectionSheetHost) -> Sheet? {
        self.host == host ? sheet : nil
    }

    /// A sheet's own close (its model finished, or its Cancel) — only the standing sheet with that id goes.
    func dismiss(_ id: UUID) {
        guard sheet?.id == id else { return }
        let closing = sheet
        sheet = nil
        host = nil
        if case .signIn(let request)? = closing { request.closed() }
    }

    /// The host's dismissal (an interactive dismiss, or the window closing under the sheet): the same as the sheet's own
    /// way out — a confirm's Cancel (a running act keeps its sheet), the Account sheet's close.
    func hostDismissed(_ host: ProtectionSheetHost) {
        guard self.host == host, let sheet else { return }
        switch sheet {
        case .signIn: dismiss(sheet.id)
        default: sheet.cancel()
        }
    }

    /// **THE LIBRARY CLOSED** (VX-239's rule on the new road): an open settled anywhere but ready — the lobby, the
    /// interlude, the missing face, a failure. The standing sheet is dropped (an idle confirm asks nothing more; a running
    /// act finishes on its own road with no sheet), so nothing re-presents after an unlock. A crossing's own reopen passes
    /// through `.opening` to ready, never here, so its confirm survives it.
    func libraryClosed() {
        guard let closing = sheet else { return }
        sheet = nil
        host = nil
        ProtectionOpenRoad.log("road: the library closed — the protection sheet standing is dropped (never re-presented)")
        if case .signIn(let request) = closing { request.closed() }
    }
}
