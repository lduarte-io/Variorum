//
//  ICloudDriveOfferTests.swift
//  VariorumTests
//
//  pre-13x batch 5b, item 0(a) — THE iCLOUD DRIVE OFFER (decision 24; copy
//  §6; ledger 64): once, at the first backup run, over the picked-folder
//  machinery. The pins drive the MODEL through scripted leaves (no panel
//  ever opens) over a scratch defaults suite: the offer is due only after a
//  run and only when the mark is unset and no second folder is picked;
//  each door's effect; the mark's variant scoping; a store that already
//  picked a folder is never asked. A new mechanism — no behavioural revert
//  exists (the brief's letter); the render pin hosts the sheet alone.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("pre-13x 5b — the iCloud Drive offer (decision 24, copy §6)", .serialized)
struct ICloudDriveOfferTests {
    /// What the scripted leaves saw.
    @MainActor
    final class Calls {
        var picksAt: [URL?] = []
        var pickReturns: URL?
        var remembered: [URL] = []
        var rememberThrows: (any Error)?
        var runs = 0
    }

    private func scratchDefaults() -> (UserDefaults, String) {
        let name = "variorum-5b-icloud-offer-\(UUID().uuidString)"
        return (UserDefaults(suiteName: name)!, name)
    }

    private func model(
        variant: AppDatabase.StoreVariant = .real, defaults: UserDefaults, posture: Posture = .standard,
        calls: Calls
    ) -> ICloudDriveOfferModel {
        ICloudDriveOfferModel(leaves: .init(
            variant: variant,
            defaults: { defaults },
            pickFolder: { at in
                calls.picksAt.append(at)
                return calls.pickReturns
            },
            remember: { url, store in
                if let error = calls.rememberThrows { throw error }
                calls.remembered.append(url)
                // The real `remember` mints a bookmark; the pins only need
                // the destination to READ as set.
                store.set(Data("bookmark".utf8), forKey: BackupDestination.defaultsKey)
            },
            backUpNow: { calls.runs += 1 },
            posture: { posture }))
    }

    private func aRun() -> BackupRunRecord {
        BackupRunRecord(at: Date(), primary: .init(outcome: .written), secondary: .init(outcome: .noDestination), markdown: nil)
    }

    /// Due only AFTER a run, only while the mark is unset and no folder is
    /// picked; *Not Now* marks it asked, and it is never due again.
    @Test func theOfferIsDueOnceAfterTheFirstRunAndNotNowAnswersItForGood() {
        let (defaults, name) = scratchDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let calls = Calls()
        let offer = model(defaults: defaults, calls: calls)
        offer.consider(after: nil)
        #expect(!offer.isDue, "no run yet — nothing is offered")
        offer.consider(after: aRun())
        #expect(offer.isDue, "the first run lands ⇒ the offer")
        offer.notNow()
        #expect(!offer.isDue)
        #expect(ICloudDriveOfferModel.isMarked(variant: .real, in: defaults))
        offer.consider(after: aRun())
        #expect(!offer.isDue, "asked once — never again after any door")
        #expect(calls.picksAt.isEmpty && calls.runs == 0, "Not Now opens no panel and runs nothing")
    }

    /// *Use iCloud Drive*: the panel opens AT iCloud Drive's root; the pick is
    /// remembered as the second destination; the mark is set; a run is
    /// forced (the 13l seed-immediately precedent); the sheet dismisses.
    @Test func useICloudDriveOpensThePanelAtTheDriveRootRemembersThePickMarksAndSeeds() async {
        let (defaults, name) = scratchDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let calls = Calls()
        let picked = ICloudDriveOfferModel.driveRoot
        calls.pickReturns = picked
        let offer = model(defaults: defaults, calls: calls)
        offer.consider(after: aRun())
        #expect(offer.isDue)
        await offer.useICloudDrive()
        #expect(calls.picksAt == [ICloudDriveOfferModel.driveRoot], "the panel opened at iCloud Drive's root")
        #expect(ICloudDriveOfferModel.driveRoot.path.hasSuffix("/Library/Mobile Documents/com~apple~CloudDocs"))
        #expect(ICloudDriveOfferModel.driveRoot.path.hasPrefix("/Users/"), "the REAL home, never the sandbox container's")
        #expect(calls.remembered == [picked], "the pick became the second destination")
        #expect(BackupDestination.isSet(in: defaults))
        #expect(calls.runs == 1, "one forced run so the first copy lands while she looks")
        #expect(!offer.isDue && ICloudDriveOfferModel.isMarked(variant: .real, in: defaults))
        #expect(offer.note == nil)
    }

    /// *Choose Another Folder…*: the existing picker (no directory hint), the
    /// same remember + mark + seed.
    @Test func chooseAnotherFolderOpensThePlainPickerAndTakesTheSameRoad() async {
        let (defaults, name) = scratchDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let calls = Calls()
        let picked = URL(fileURLWithPath: "/Volumes/Backups/Variorum", isDirectory: true)
        calls.pickReturns = picked
        let offer = model(defaults: defaults, calls: calls)
        offer.consider(after: aRun())
        await offer.chooseAnotherFolder()
        #expect(calls.picksAt == [nil], "the plain picker — the panel's own default folder")
        #expect(calls.remembered == [picked] && calls.runs == 1)
        #expect(!offer.isDue && ICloudDriveOfferModel.isMarked(variant: .real, in: defaults))
    }

    /// A CANCELLED panel (iCloud Drive not on this Mac, or she backed out):
    /// one line, the sheet stays, the mark UNSET — *Not Now* is the answer,
    /// never a cancel. A refused bookmark says its reason and changes nothing.
    @Test func aCancelledPickLeavesTheOfferOpenAndUnmarkedWithOneLine() async {
        let (defaults, name) = scratchDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let calls = Calls()
        calls.pickReturns = nil
        let offer = model(defaults: defaults, calls: calls)
        offer.consider(after: aRun())
        await offer.useICloudDrive()
        #expect(offer.isDue, "the sheet stays")
        #expect(offer.note == ProtectionCopy.iCloudOfferNoFolderPicked)
        #expect(!ICloudDriveOfferModel.isMarked(variant: .real, in: defaults) && calls.runs == 0 && calls.remembered.isEmpty)
        // A pick the sandbox cannot keep: the refusal's own words, nothing marked.
        calls.pickReturns = URL(fileURLWithPath: "/tmp/x", isDirectory: true)
        calls.rememberThrows = BackupDestination.MintFailure(reason: "scripted refusal")
        await offer.chooseAnotherFolder()
        #expect(offer.isDue && offer.note == "scripted refusal")
        #expect(!ICloudDriveOfferModel.isMarked(variant: .real, in: defaults) && calls.runs == 0)
    }

    /// The mark is per store VARIANT: a dev-store answer never suppresses the
    /// real store's offer, and the reverse.
    @Test func theMarkIsScopedByStoreVariant() {
        let (defaults, name) = scratchDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        let dev = model(variant: .dev, defaults: defaults, calls: Calls())
        dev.consider(after: aRun())
        dev.notNow()
        #expect(ICloudDriveOfferModel.isMarked(variant: .dev, in: defaults))
        #expect(!ICloudDriveOfferModel.isMarked(variant: .real, in: defaults))
        let real = model(variant: .real, defaults: defaults, calls: Calls())
        real.consider(after: aRun())
        #expect(real.isDue, "the real store is still owed its offer")
        #expect(ICloudDriveOfferModel.markKey(for: .dev) != ICloudDriveOfferModel.markKey(for: .real))
    }

    /// A store that ALREADY has a second folder picked is marked silently at
    /// its first run — the question is answered by the pick that exists.
    @Test func aStoreWithAFolderAlreadyPickedIsNeverAskedAndIsMarkedQuietly() {
        let (defaults, name) = scratchDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        defaults.set(Data("bookmark".utf8), forKey: BackupDestination.defaultsKey)
        let offer = model(defaults: defaults, calls: Calls())
        offer.consider(after: aRun())
        #expect(!offer.isDue)
        #expect(ICloudDriveOfferModel.isMarked(variant: .real, in: defaults), "marked — never asked later either")
    }

    /// The sheet renders copy §6 verbatim — the title, the body, the addendum
    /// by POSTURE, the three doors — hosted alone in a window (the
    /// mechanism-only rule).
    @Test func theSheetRendersCopySixByPosture() async {
        let (defaults, name) = scratchDefaults()
        defer { defaults.removePersistentDomain(forName: name) }
        for posture in [Posture.standard, Posture.castle] {
            let offer = model(defaults: defaults, posture: posture, calls: Calls())
            offer.consider(after: aRun())
            let sheet = ICloudDriveOfferSheet(model: offer)
            await SurfaceComposition.host(sheet, size: NSSize(width: 500, height: 300))
            let shown = SurfaceComposition.text(of: sheet.body)
            #expect(SurfaceComposition.carries(ProtectionCopy.iCloudOfferTitle, in: shown))
            #expect(SurfaceComposition.carries(ProtectionCopy.iCloudOfferBody, in: shown))
            let expected = posture == .castle ? ProtectionCopy.iCloudOfferCastleAddendum : ProtectionCopy.iCloudOfferStandardAddendum
            let other = posture == .castle ? ProtectionCopy.iCloudOfferStandardAddendum : ProtectionCopy.iCloudOfferCastleAddendum
            #expect(SurfaceComposition.carries(expected, in: shown), "\(posture)'s addendum")
            #expect(!SurfaceComposition.carries(other, in: shown), "not the other posture's")
            for door in [ProtectionCopy.iCloudOfferUseDoor, ProtectionCopy.iCloudOfferChooseDoor, ProtectionCopy.iCloudOfferNotNowDoor] {
                #expect(SurfaceComposition.carries(door, in: shown), "the door \(door)")
            }
        }
        // The copy, byte-exact (render-don't-re-derive: the sheet reads these).
        #expect(ProtectionCopy.iCloudOfferTitle == "Keep a copy of your backups in iCloud Drive?")
        #expect(ProtectionCopy.iCloudOfferBody == "Variorum keeps backups beside your library, on this Mac. A copy in iCloud Drive survives the Mac.")
        #expect(ProtectionCopy.iCloudOfferStandardAddendum == "Your Apple account then holds both the key and the writing.")
        #expect(ProtectionCopy.iCloudOfferCastleAddendum == "Backups are encrypted; the copy is safe anywhere.")
        #expect(ProtectionCopy.liveLibraryNotInICloudDrive.hasPrefix("Your working library stays on this Mac. iCloud Drive syncs files while they're being written"))
    }
}
