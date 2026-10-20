//
//  ProtectionSheetPresenterTests.swift
//  VariorumTests — VX-308 U1 piece 2: THE ONE PRESENTER (VX-239 + VX-243's rule on the new road; the U1 ARBITRATION's
//  R-6). One protection sheet at a time; only its host scene presents it (never two windows); a sheet's own close and
//  the host's dismissal are its Cancel (a running act keeps its sheet); the library closing DROPS the sheet, and an act
//  still running under it never brings it back. The crossings' confirm is presented through it, its contents unchanged.
//  Pure (also runs headless in the implementer's SwiftPM harness).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-308 U1 — the one presenter for the protection sheets")
@MainActor
struct ProtectionSheetPresenterTests {
    static let otherWindow = ProtectionSheetHost(scene: "another window")
    static let wordsText = ((try? RecoveryPhrase.generate()) ?? []).joined(separator: " ")

    private func confirm(
        act: @escaping (RoadCrossingRequest) async -> RoadCrossingPress = { _ in .refused("x") },
        finished: @escaping (RoadCrossingPress?) -> Void = { _ in }
    ) -> RoadCrossingConfirmModel {
        RoadCrossingConfirmModel(door: PlantedCrossingRoads.useCastle(), act: act, finished: finished)
    }

    @Test func oneSheetAtATimeAndOnlyItsHostPresentsIt() {
        let presenter = ProtectionSheetPresenter()
        let first = confirm()
        #expect(presenter.present(.crossing(first), on: .settings))
        #expect(!presenter.present(.crossing(confirm()), on: .settings), "a second sheet never stands beside the first")
        #expect(!presenter.present(.crossing(confirm()), on: Self.otherWindow))
        #expect(presenter.sheet?.id == first.id)
        #expect(presenter.sheet(for: .settings)?.id == first.id)
        #expect(presenter.sheet(for: Self.otherWindow) == nil, "VX-243: no second window shows it")
    }

    @Test func aSheetGoesOnlyByItsOwnIDAndTheHostsDismissalIsItsCancel() {
        let presenter = ProtectionSheetPresenter()
        var finished: [RoadCrossingPress?] = []
        var id: UUID?
        let model = confirm(finished: { press in
            finished.append(press)
            if let id { presenter.dismiss(id) }
        })
        id = model.id
        presenter.present(.crossing(model), on: .settings)
        presenter.dismiss(UUID())
        #expect(presenter.sheet?.id == model.id, "another id closes nothing")
        presenter.hostDismissed(Self.otherWindow)
        #expect(presenter.sheet?.id == model.id && finished.isEmpty, "only its host's dismissal reaches it")
        presenter.hostDismissed(.settings)
        #expect(presenter.sheet == nil && finished.count == 1 && finished[0] == nil, "the host's dismissal is Cancel")
        #expect(presenter.present(.crossing(confirm()), on: .settings), "the floor is free again")
    }

    /// VX-239: the library closing drops the standing sheet — and a confirm whose act was still running finishes on its
    /// own road with no sheet: nothing re-presents after the next unlock.
    @Test func theLibraryClosingDropsTheSheetAndARunningActNeverBringsItBack() async {
        let presenter = ProtectionSheetPresenter()
        let gates = ReadGates()
        var id: UUID?
        let model = confirm(
            act: { _ in
                _ = await gates.wait()
                return .refused(ProtectionWords.crossingFailed)
            },
            finished: { _ in if let id { presenter.dismiss(id) } })
        id = model.id
        presenter.present(.crossing(model), on: .settings)
        let press = Task { await model.submit(passphrase: "a new passphrase", again: "a new passphrase", words: Self.wordsText) }
        await gates.waitForCalls(1)
        #expect(model.busy)
        presenter.libraryClosed()
        #expect(presenter.sheet == nil && presenter.sheet(for: .settings) == nil)
        gates.release(1)
        await press.value
        #expect(model.refusal == ProtectionWords.crossingFailed, "the act finished on its own road")
        #expect(presenter.sheet == nil, "and its sheet never came back")
        presenter.libraryClosed()
        #expect(presenter.sheet == nil, "a second close with nothing standing is a no-op")
    }

    /// The Account sheet (sign in — R-5): its close, by any road, tells the face that asked for it.
    @Test func theAccountSheetsCloseIsHeardByItsFace() {
        let presenter = ProtectionSheetPresenter()
        var closes = 0
        let request = ProtectionSignInRequest { closes += 1 }
        presenter.present(.signIn(request), on: .settings)
        presenter.hostDismissed(.settings)
        #expect(presenter.sheet == nil && closes == 1)
        let again = ProtectionSignInRequest { closes += 1 }
        presenter.present(.signIn(again), on: .settings)
        presenter.libraryClosed()
        #expect(presenter.sheet == nil && closes == 2)
    }

    /// A standing sheet hands the floor to its successor in place, on its host; a sheet no longer standing hands nothing.
    @Test func aSheetHandsTheFloorToItsSuccessorInPlace() {
        let presenter = ProtectionSheetPresenter()
        let first = confirm(), second = confirm()
        presenter.present(.crossing(first), on: .settings)
        #expect(presenter.replace(first.id, with: .crossing(second)))
        #expect(presenter.sheet(for: .settings)?.id == second.id)
        #expect(!presenter.replace(first.id, with: .crossing(confirm())), "the first no longer stands")
    }

    /// The crossings' confirm is presented THROUGH the presenter (one home): the door opens its confirm there, another
    /// standing sheet blocks it, and the confirm's own close frees the floor — its contents untouched.
    @Test func theCrossingsConfirmLivesOnThePresenter() async throws {
        let presenter = ProtectionSheetPresenter()
        let planted = PlantedCrossingRoads()
        planted.faces = PlantedCrossingRoads.faces()
        let crossings = RoadCrossingsModel(roads: planted.roads, presenter: presenter)
        await crossings.refresh()
        let signIn = ProtectionSignInRequest {}
        presenter.present(.signIn(signIn), on: .settings)
        crossings.open(.useCastle)
        #expect(crossings.confirm == nil, "another protection sheet stands")
        presenter.dismiss(signIn.id)
        crossings.open(.useCastle)
        let confirm = try #require(crossings.confirm)
        #expect(presenter.sheet(for: .settings)?.id == confirm.id)
        #expect(confirm.door == PlantedCrossingRoads.useCastle(), "the door as `assess` gave it — contents unchanged")
        confirm.cancel()
        #expect(crossings.confirm == nil && presenter.sheet == nil)
    }
}
