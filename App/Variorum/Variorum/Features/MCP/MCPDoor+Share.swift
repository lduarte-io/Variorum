//
//  MCPDoor+Share.swift
//  Variorum (MAC ONLY)
//
//  13n-c U3 — THE SHARE ROAD's ACTS (VX-156 items 2/3; VX-270). The door's
//  second file: everything a place-door, ⌥⌘A and a receipt's doors do — each
//  through the session's runner (P2), each speaking on the WINDOW's status
//  seam (a receipt that carries its Change… and Revoke › doors, or the
//  operation's own refusal). The pane's sheet keeps its own caption (13n-b) —
//  only a sheet opened from a PLACE speaks here.
//

import Foundation
import VariorumCore

extension MCPDoor {
    // MARK: - From the sheet

    /// **One grant from THE sheet** — Change… when `replacing` names grants
    /// (T-U3-8: replaced in the same act). `saying` is the place as a receipt
    /// says it; nil = the pane's own sheet, which speaks only a refusal, in
    /// its caption (13n-b's road, unchanged). `change` re-opens the sheet in
    /// the window that asked (the receipt's Change…).
    func grant(
        _ client: MCPClient, _ spec: Operations.MCPGrantSpec, replacing: [String],
        saying place: String?, change: ((MCPGrantOpening) -> Void)?
    ) {
        let prefill: MCPGrantPrefill = switch spec.scopeKind {
        case .note: .note(spec.scopeID)
        case .book: .book(spec.scopeID)
        case .wing: .wing(spec.scopeID)
        }
        share(client: client, prefill: prefill, rung: spec.rung, duration: spec.duration,
              replacing: replacing, saying: place, change: change) { ops in
            [try ops.grantMCPAccess(client.id, spec, replacing: replacing)]
        }
    }

    /// **Several notes from THE sheet** (the Library's "Share N notes…"): ONE
    /// act on one stamp — `grantMCPAccess(_:notes:…)`; any refusal refuses it
    /// whole.
    func grantNotes(
        _ client: MCPClient, _ noteIDs: [String], rung: MCPGrantRule.Rung,
        duration: MCPGrantRule.Duration, replacing: [String], saying place: String?,
        change: ((MCPGrantOpening) -> Void)?
    ) {
        share(client: client, prefill: .notes(noteIDs), rung: rung, duration: duration,
              replacing: replacing, saying: place, change: change) { ops in
            try ops.grantMCPAccess(
                client.id, notes: noteIDs, rung: rung, duration: duration, replacing: replacing)
        }
    }

    private func share(
        client: MCPClient, prefill: MCPGrantPrefill, rung: MCPGrantRule.Rung,
        duration: MCPGrantRule.Duration, replacing: [String], saying place: String?,
        change: ((MCPGrantOpening) -> Void)?,
        body: @escaping @Sendable (Operations) throws -> [String]
    ) {
        guard let runner else { return }
        note = nil
        let status = session?.status
        Task { @MainActor [weak self] in
            do {
                let ids = try await runner.run(body)
                guard let place else { return }
                self?.speakShared(
                    client: client, prefill: prefill, place: place, rung: rung, duration: duration,
                    grantIDs: ids, changed: !replacing.isEmpty, change: change)
            } catch {
                if place != nil {
                    status?.refuse(MCPPaneCopy.refusal(error))
                } else {
                    self?.note = Note(text: MCPPaneCopy.refusal(error), place: .top)
                }
            }
        }
    }

    // MARK: - Change… on a Shared-with-AI row (13n-c UX walk W-UX-19)

    /// **W-UX-19 (her ask, sitting round 8 — "I see these grants here and I
    /// can revoke them but I don't see a way to upgrade them"):** a row's
    /// Change… opens THE replace sheet pre-filled on exactly that grant — the
    /// receipt's and the popovers' idiom (`MCPReachPopover.changeOpening`),
    /// opened from the PANE (its sheet speaks in the pane's caption). The
    /// client is read NOW; the sheet reads the target's facts at its open (a
    /// grant inert since opens on what it can take now — the B2 lesson).
    func changeOpening(_ row: MCPSharedRow) async -> MCPGrantOpening? {
        guard let client = await client(row.grant.clientID) else { return nil }
        var opening = MCPReachPopover.changeOpening(client, row.grant)
        opening.origin = .pane
        return opening
    }

    /// W-UX-19 — an ACT's Change… (a grouped row: several note grants minted
    /// in one act): it covers the act's grants as the row's one Revoke does —
    /// every member, read now, in the act's order, replaced in one act.
    func changeOpening(act group: MCPSharedGroup) async -> MCPGrantOpening? {
        guard let client = await client(group.lead.grant.clientID),
              let members = await sharedMembers(group.grantIDs), !members.isEmpty
        else { return nil }
        return Self.changeOpening(act: client, members: members)
    }

    /// One client, read now (nil when gone or the read fails).
    private func client(_ id: String) async -> MCPClient? {
        guard let database else { return nil }
        return (try? await database.read { db in try Queries.mcpClient(db, id: id) }) ?? nil
    }

    /// The act's replace opening, pure (pinned): WHERE = the members' notes in
    /// the act's order, the act's rung and duration, replacing EVERY member.
    nonisolated static func changeOpening(act client: MCPClient, members: [MCPSharedRow]) -> MCPGrantOpening {
        let lead = members[0].grant
        return MCPGrantOpening(
            client: client, place: .notes(members.map(\.grant.scopeID)), rung: lead.rung,
            duration: lead.duration, replacing: members.map(\.grant.id), origin: .pane)
    }

    // MARK: - ⌥⌘A

    /// **⌥⌘A — share the note you're in** (13n-c U3; the brief §4 + mockup
    /// §3, D1 — `MCPShareChord`): the newest grant she made names the client
    /// and the rung; while connected if that client is connected now, else
    /// once — never always by a key. No history ⇒ THE sheet with WHERE = this
    /// note (`openSheet` — the window's road); that client already reaching
    /// the note at the rung ⇒ the refusal, nothing written. The receipt
    /// carries Change… (VX-270) and Revoke ›.
    func shareThisNote(_ postID: String, openSheet: @escaping (MCPGrantOpening) -> Void) async {
        guard let session, let database, let runner else { return }
        let connectedNames = connected
        do {
            let (newest, client, reached, title) = try await database.read { db in
                let newest = try Queries.mcpNewestGrant(db)
                let client = try newest.flatMap { try Queries.mcpClient(db, id: $0.clientID) }
                let reached = try newest.flatMap { newest in
                    try Queries.mcpNoteReach(db, noteID: postID).first { $0.clientID == newest.clientID }?.rung
                }
                return (newest, client, reached, try Queries.mcpScopeTitle(db, kind: .note, id: postID))
            }
            let outcome = MCPShareChord.decide(
                newest: newest, connected: newest.map { connectedNames.contains($0.clientName) } ?? false,
                reached: reached)
            switch outcome {
            case .openSheet:
                openSheet(MCPGrantOpening(place: .note(postID), origin: .place))
            case .alreadyReaching(let name, let rung):
                session.status.refuse(MCPShareCopy.alreadyReaches(name, rung))
            case .grant(let clientID, _, let rung, let duration):
                guard let client else { return }
                let spec = Operations.MCPGrantSpec(rung: rung, scopeKind: .note, scopeID: postID, duration: duration)
                let id = try await runner.run { try $0.grantMCPAccess(clientID, spec) }
                speakShared(
                    client: client, prefill: .note(postID),
                    place: MCPShareCopy.quoted(title ?? postID), rung: rung, duration: duration,
                    grantIDs: [id], changed: false, change: openSheet)
            }
        } catch {
            session.status.refuse(MCPPaneCopy.refusal(error))
        }
    }

    // MARK: - The receipt and its two doors

    /// The receipt (app voice): what was shared, with whom, how far and for
    /// how long — carrying **Revoke ›** (the act's own grants, one act) and
    /// **Change…** (VX-270: the sheet pre-filled on exactly what landed;
    /// confirming REPLACES it — T-U3-8).
    func speakShared(
        client: MCPClient, prefill: MCPGrantPrefill, place: String, rung: MCPGrantRule.Rung,
        duration: MCPGrantRule.Duration, grantIDs: [String], changed: Bool,
        change: ((MCPGrantOpening) -> Void)?
    ) {
        guard let session else { return }
        let text = changed
            ? MCPShareCopy.changed(place: place, client: client.name, rung: rung, duration: duration)
            : MCPShareCopy.shared(place: place, client: client.name, rung: rung, duration: duration)
        let revoke = StatusCenter.Item.Action(label: MCPShareCopy.revokeDoor) { [weak self] in
            Task { await self?.revokeFromReceipt(grantIDs) }
        }
        let changeDoor = change.map { open in
            StatusCenter.Item.Action(label: MCPShareCopy.changeDoor) {
                open(MCPGrantOpening(
                    client: client, place: prefill, rung: rung, duration: duration,
                    replacing: grantIDs, origin: .place))
            }
        }
        session.status.deliver(text, kind: .receipt, action: revoke, secondary: changeDoor)
    }

    /// A receipt's (or a popover's) Revoke: the named grants, one act, and the
    /// honest word either way.
    func revokeFromReceipt(_ grantIDs: [String]) async {
        guard let runner, let session else { return }
        do {
            try await runner.run { try $0.revokeMCPGrants(grantIDs) }
            session.status.receipt(MCPShareCopy.revoked)
        } catch {
            session.status.refuse(MCPPaneCopy.refusal(error))
        }
    }
}
