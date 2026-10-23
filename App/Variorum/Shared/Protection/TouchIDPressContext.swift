//
//  TouchIDPressContext.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-487 (b) — ONE PRESS COVERS BOTH GATED READS (`notes/plans/fixes/vx-488-window-hotfixes.md`, M1). Under Castle with
//  Touch ID the lobby's press reads the library key's Touch ID item (`KeychainCustodyLeaf` — the system prompt) and, for a
//  library bound to an account, the account's Touch ID sync-keys item (rule 15's custody) — which the engine's provider
//  never reads itself (a press per round is nobody's wish; P-VX307-U1-3: "rounds run while an act or unlock has loaded
//  session memory"). Each leaf used to mint its own `LAContext`, so a second read would prompt again. Now the custody leaf
//  HANDS the press it evaluated to its caller (`TouchIDPressHanding` — never kept by the leaf), and the sync-keys leaf
//  READS RIDING it (`TouchIDPressRiding`): the keychain answers a read under an already-authenticated context without
//  asking (SecItem.h, `kSecUseAuthenticationContext`), and the ride sets `interactionNotAllowed`, so it can never show UI —
//  a read the press does not cover fails (`errSecInteractionNotAllowed`) instead of prompting. `ProtectionOpenRoad
//  .pressTouchID` ends the press (`invalidate`) on every path. App-level by design: the core's leaves (`CustodyLeaf`,
//  `SyncKeysLeaf`) know nothing of LocalAuthentication.
//

import Foundation
import LocalAuthentication
import VariorumCore

/// One Touch ID moment — the `LAContext` a gated read evaluated. Never logged, never kept past the press that made it.
nonisolated final class TouchIDPressContext: @unchecked Sendable, CustomStringConvertible {
    let context: LAContext
    private let lock = NSLock()
    private var ended = false

    init(_ context: LAContext = LAContext()) { self.context = context }

    /// The press ends: the context authorizes nothing more.
    func invalidate() {
        lock.withLock { ended = true }
        context.invalidate()
    }

    /// Whether the press has ended (the road's own check, and the pins').
    var isInvalidated: Bool { lock.withLock { ended } }

    var description: String { "TouchIDPressContext(redacted)" }
}

/// A custody leaf whose Touch ID read hands its caller the press it evaluated (the production leaf; a test's planted one).
nonisolated protocol TouchIDPressHanding: AnyObject {
    /// The library key's Touch ID item read exactly as `readCustody(fingerprint:itemClass: .touchid)` reads it (the same
    /// prompt, the same press facts) — plus the press it evaluated, nil when the read did not open its item. The caller
    /// owns the press and ends it.
    func readTouchIDCustody(fingerprint: String) throws -> (key: StoreKey?, press: TouchIDPressContext?)
}

/// A sync-keys leaf that reads an account's Touch ID item riding a press already evaluated — never a second prompt.
nonisolated protocol TouchIDPressRiding: AnyObject {
    /// nil: no such item. Throws on any other keychain answer — `errSecInteractionNotAllowed` when the press does not
    /// cover the item (nothing shown, nothing read).
    func readSyncKeys(accountID: String, riding press: TouchIDPressContext) throws -> AccountKeys?
}
