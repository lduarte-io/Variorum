//
//  ProtectionAccountActs.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-308 U1 — THE ACCOUNT SECTION'S ROADS on the open library, off the main actor (`notes/plans/vx-308-accounts-key-
//  doors.md` §5a and its U1 ARBITRATION; the contract `notes/CastleRules.md` rules 7, 14, 16). Through the session's
//  executor — the one thing that writes — and NOTHING HERE DECIDES: `assess` says what each door is, the core's acts do
//  what the rules say, on their sealed plans (rule 20).
//
//    - THE PANE'S ONE READ (`ProtectionPaneRead.read` — R-2): `assess` over the open library's facts with the CURRENT
//      sign-in (read now: the open's is stale once she signs in or out) and a FRESH vault read for the signed-in account
//      (decision 35 — a synced door without one refuses `.needsFreshVault`; a local library needs it to tell setting sync
//      up from a join). The crossings' faces and the account faces derive from this one read, and both doors' press-time
//      re-reads (VX-108) read the same way, so a shown door and its re-read always compare like with like. The vault is
//      read through the leaf directly — the executor's own cache is the acts' (each act reads the vault it acts on).
//

import Foundation
import VariorumCore

/// The pane's one read: the facts `assess` reads, and what the vault read found.
nonisolated struct ProtectionPaneFacts: Sendable {
    var facts: ProtectionFacts
    var vault: VaultReadState
}

nonisolated enum ProtectionPaneRead {
    /// **THE PANE'S ONE READ** (a READ): the open library's facts with `signIn` (the sign-in now) and the signed-in
    /// account's vault, read fresh; this Mac's scheduled export as the weekly copy's switch says it (U2a's
    /// P-VX307-U2a-3). nil: the facts could not be read (logged) — the pane shows no door rather than a guess.
    static func read(
        _ session: ProtectionRoadSession, signIn: SessionFact, exportSwitch: ScheduledExportSwitch?
    ) async -> ProtectionPaneFacts? {
        var facts: ProtectionFacts
        do {
            facts = try session.system.facts(session: signIn, unlocked: session.library)
        } catch {
            ProtectionOpenRoad.log("road: the pane's facts could not be read — \(String(describing: error))")
            return nil
        }
        if let exportSwitch { facts.unlocked?.thisMac.settings.scheduledExport = exportSwitch.isOn() }
        guard let account = signIn.accountID else { return ProtectionPaneFacts(facts: facts, vault: .notAsked) }
        do {
            let snapshot = try await session.system.leaves.vault.fetchVault(accountID: account)
            facts.vault = snapshot?.reading
            return ProtectionPaneFacts(facts: facts, vault: .read(exists: snapshot != nil))
        } catch {
            ProtectionOpenRoad.log("road: the account's vault could not be read — \(String(describing: error))")
            return ProtectionPaneFacts(facts: facts, vault: .unreachable)
        }
    }

    /// The account section's faces from one read.
    static func accountFaces(_ read: ProtectionPaneFacts) -> RoadAccountFaces? {
        RoadAccountFaces.derive(read.facts, assess(read.facts), vault: read.vault)
    }
}
