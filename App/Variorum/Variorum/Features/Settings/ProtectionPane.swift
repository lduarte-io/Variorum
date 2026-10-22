//
//  ProtectionPane.swift
//  Variorum
//
//  Settings ▸ Protection — the protection road's sections (`notes/CastleRules.md`; SurfaceContracts, Doors ▸ Library
//  protection): *Set a passphrase…* while none exists (VX-306 U2), the key doors (VX-308 U3), the twelve words' look
//  (VX-307 U2b), the crossings with the Castle-only "On this Mac" section (VX-307 U2a, VX-309 U1c), the account section
//  (VX-308 U1), and the one line every posture shows. Every door reads `assess`'s state through the bootstrap's
//  `RoadStandingModel`; every sheet presents through the one presenter.
//
//  VX-329 U1 (the release switch): today's rows — the pre-13x posture cards, the live checklist, 17m's Re-link, Castle's
//  today-switches, the 13p passphrase set sheet and its reminder, the notice bar, the follow, migration and ceremony
//  sheets — were today's road and were deleted with it.
//

import SwiftUI
import VariorumCore

// MARK: - The pane

struct ProtectionPane: View {
    let services: AppServices?
    /// The open library's protection faces (nil while no library is open on the road — only the closing line shows).
    var roadStanding: RoadStandingModel? = nil
    @State private var roadSheet: SetPassphraseModel?

    var body: some View {
        Form {
            // VX-306 ladder round 1, NIT 4: the row only while the library has no passphrase (P-2).
            if let roadStanding, roadStanding.offersSetPassphrase {
                roadPassphraseSection(roadStanding)
            }
            // VX-308 U3: the key doors where a passphrase exists — Change passphrase…, Reset forgotten passphrase… (as
            // `assess` says them over the pane's one read; *Set a passphrase…* above stands in their place otherwise).
            if let keyDoors = roadStanding?.keyDoors {
                RoadKeyDoorsSection(model: keyDoors)
            }
            // VX-307 U2b (rules 2 and 7 as amended): the twelve words' door — the one the card's ✕ names ("look in
            // Settings, Protection"). A look mints fresh words through rule 6's act; nothing keeps them. VX-308 U3: this
            // door is the key doors' New Words (its face read from `assess`, its refusal in its place).
            if let roadStanding, roadStanding.band != nil {
                WordsLookSection(standing: roadStanding, keyDoors: roadStanding.keyDoors)
            }
            // VX-307 U2a: the crossings — the posture, Use Castle / Use Standard / Replace All Keys as `assess` says them,
            // rule 11's notice, the gate-style row.
            if let crossings = roadStanding?.crossings {
                RoadCrossingsSection(model: crossings)
            }
            // VX-308 U1: the account section — the situation and its doors as `assess` says them (turning sync on, the
            // three local leaves, sign in and out).
            if let account = roadStanding?.account {
                RoadAccountSection(model: account)
            }
            keystoneSection
        }
        .formStyle(.grouped)
        // VX-307 U2a: the crossings' doors re-read at each appearance (a crossing's reopen rebuilds this pane); VX-308 U1
        // and U3: the account section's and the key doors' with them — ONE read for the three (the ladder's round-1
        // MINOR-2: R-2's one assessment, one vault fetch per appearance).
        .task { await roadStanding?.refreshPane() }
        // VX-308 U1 (VX-239 + VX-243): every protection sheet — the crossings' confirm, the account's, the signed-out
        // screen, sign in and out — through THE ONE PRESENTER (the bootstrap's, so a crossing's confirm survives the
        // reopen under it), presented here, its host, alone.
        .protectionSheets(roadStanding?.sheets, services: services)
        // VX-306 U2: the set-passphrase sheet (this pane's own — the main window's bar holds its own).
        .sheet(item: $roadSheet) { model in
            SetPassphraseSheet(model: model)
        }
    }

    // MARK: VX-306 U2 — the one row

    /// The ask's other home (P-VX306-U2-0 (a)): one row, *Set a passphrase…* — rendered only while no passphrase exists
    /// (`RoadStandingModel.offersSetPassphrase`; the sheet still refuses if one appears meanwhile).
    private func roadPassphraseSection(_ standing: RoadStandingModel) -> some View {
        Section {
            HStack {
                Button(ProtectionWords.reminderSetDoor) {
                    roadSheet = standing.makeSetPassphraseSheet { roadSheet = nil }
                }
                Spacer()
            }
        }
    }

    // MARK: The one line every posture shows

    private var keystoneSection: some View {
        Section {
            Text(ProtectionCopy.keystoneOpenMeansReadable)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
