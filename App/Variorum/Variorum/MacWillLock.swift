//
//  MacWillLock.swift
//  Variorum (Mac)
//
//  Pre-13u Act 9 (17a P3) — THE MAC'S LOCK TEARDOWN, mirroring the quit
//  door at last. The re-lock's `onWillLock` used to run only the
//  quit-finalize registry + services.stop() — but the registry's closures
//  are `savepointOnLeaving` (flush + closeAutoCommit), and the OPEN TAIL
//  has no variant, so neither line can reach it. Only
//  `EditorViewModel.finalizeWork()` awaits the pending cross-block
//  compound (its own comment: "quit/teardown must let it land or the
//  gesture is silently un-applied"), waits out an in-flight mint, and
//  crystallizes the residual tail — and the lock road reached none of
//  that. Concrete loss: with relock-on-sleep on, type a paragraph at the
//  end of a note (in `one_block` segmentation the whole entry is the open
//  tail) and let the screen lock inside the ~2 s tail debounce — the text
//  was on screen, in no row, and the lobby replaced the view; the late
//  `.onDisappear` teardown then raced the closed pool into a
//  `StoreLockedError` on a view that no longer existed.
//
//  A FACTORY rather than an inline closure, exactly like the phone's
//  `mobileWillLock` (MobileRelock.swift) and for the same reason: the
//  scripted pin wires what production wires.
//
//  ORDER IS LOAD-BEARING (the ruled teardown order): the active editor's
//  full finalize FIRST (tail crystallized, compound landed, buffer
//  flushed), then every registered note's leaving savepoint, then the
//  services stop — all before the state flips and the pool closes.
//
//  Inherited corner, recorded: like the QUIT door it mirrors, only the
//  ACTIVE editor gets the full `finalizeWork` — a second window's open
//  tail rides the registry's flush-only closure on both roads. The two
//  doors now behave identically; widening both is a design act, not P3's.
//

import Foundation

//  VX-394 (VX-348 U5): `endingConnections` — the MCP door says each live
//  connection's end ("the library locked or closed") in the activity log —
//  runs AFTER every note's leaving savepoint and BEFORE the services stop: the
//  store must still be open for its one write, and nothing of hers waits on
//  it. A no-op by default, so every other caller (and the scripted pins)
//  wires what it wired before.
@MainActor
func macWillLock(
    session: AppSession,
    endingConnections: @escaping @MainActor () async -> Void = {},
    stopServices: @escaping @MainActor () -> Void
) -> @MainActor () async -> Void {
    {
        // 17o batch b's ladder, R1-4: locking the store is a leave-the-note
        // event of the quit door's kind — the caret place is written first,
        // synchronously, like the quit door does.
        session.commandRouter.persistCurrentBlocks()
        if let pending = session.editorRouter.active?.finalizeWork() {
            await pending.value
        }
        await session.quitFinalize.finalizeAll()
        await endingConnections()
        stopServices()
    }
}

/// **THE MAC'S LOCK TEARDOWN AS PRODUCTION COMPOSES IT** (VX-394 — VX-548 batch
/// 2b): `macWillLock` with the MCP door's two steps in their ruled places — each
/// live connection's end said while the store is still open (`recordLibraryClosing`,
/// after every note's leaving savepoint: "‹client› was disconnected when the library
/// locked or closed"), then the services stop and the door detaches (A-8 — a locked
/// library serves no one; the next unlock's ready re-attaches it). Every road that
/// closes the open library runs it through `AppBootstrap.onWillLock`: Lock Library
/// Now (⌃⌘L, the File menu, Settings ▸ Protection), Castle's monitors (sleep, screen
/// lock, the idle dial) and the re-keying reopens (the crossings, the account acts,
/// Make this my library, a plain-text export brought in). ONE named composition —
/// `VariorumApp` wires exactly this — so the sweep's pin drives what ships
/// (`MCPStopRoadsDoorTests`); it used to be an inline closure no pin reached.
///
/// **VX-818 (the VX-809 run, batch 4 — her R-818; A-809-20/-21): the server
/// SURVIVES the lock.** `road` reads which road is tearing down
/// (`AppBootstrap.willLockRoad`, set just before each `onWillLock`). On the LOCK
/// and the re-keying REOPEN of the same library (P-809-13) the door's two steps
/// keep their places and change their act: the connections step SUSPENDS the
/// host instead of saying each end (nothing ends — the listener listens, every
/// connection lives on, every call answers the locked sentence), and the stop
/// step lets HER session's faces go while the host stays held; the next ready
/// resumes it on the same connections (`MCPDoor.reconcileServer`). Every other
/// road — adopt, swap, and an unset or unknown road (the default here, so a
/// caller that names none keeps today's teardown) — runs exactly the steps it
/// ran before, byte for byte: FAIL-CLOSED. `macWillLock`'s order is untouched.
@MainActor
func macLockTeardown(
    session: AppSession,
    door: MCPDoor,
    road: @escaping @MainActor () -> AppBootstrap.WillLockRoad? = { nil },
    stopServices: @escaping @MainActor () -> Void
) -> @MainActor () async -> Void {
    macWillLock(
        session: session,
        endingConnections: {
            if mcpServerSurvives(road()) {
                await door.suspendForLock()
            } else {
                await door.recordLibraryClosing()
            }
        }
    ) {
        stopServices()
        if mcpServerSurvives(road()) {
            door.detachForLock()
        } else {
            door.detach()
        }
    }
}

/// **THE LOCK TEARDOWN AS `VariorumApp` WIRES IT** (VX-818): the road read from
/// the bootstrap that runs it (`AppBootstrap.willLockRoad`, assigned just before
/// each `onWillLock`) — ONE composition the app and its pins share.
@MainActor
func macLockTeardown(
    session: AppSession,
    door: MCPDoor,
    bootstrap: AppBootstrap,
    stopServices: @escaping @MainActor () -> Void
) -> @MainActor () async -> Void {
    macLockTeardown(
        session: session, door: door, road: { [weak bootstrap] in bootstrap?.willLockRoad },
        stopServices: stopServices)
}

/// **Which teardowns keep the MCP server** (VX-818 — A-809-21's fail-closed
/// rule, widened to the re-key at the coordinator's word): the lock and the
/// re-keying reopen of the same library only. Adopt, swap and anything unnamed
/// tear it down as before. Pure; pinned.
func mcpServerSurvives(_ road: AppBootstrap.WillLockRoad?) -> Bool {
    switch road {
    case .lock?, .reKey?: true
    case .closing?, nil: false
    }
}
