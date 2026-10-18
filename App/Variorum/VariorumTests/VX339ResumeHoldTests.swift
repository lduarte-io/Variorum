//
//  VX339ResumeHoldTests.swift
//  VariorumTests
//
//  VX-339 (VX-348 U1 — the run record `notes/plans/fixes/vx-348-prelaunch-sweep.md`,
//  U1 UNIT RECORD): RESUME SYNC CLEARED THE HOLD BANNER EVEN WHEN REMOVING THE
//  MARKER FAILED. Her ruling (2026-10-14, VX-266 design §9 call 4): "yeah we
//  can do the small bug fix." The shape: clear the banner only once the marker
//  is gone; on failure say so and keep the hold visible.
//
//  The mechanism (VX-317's trace): `RestoreHoldModel.resume()` called
//  `LibraryRestoreHold.clear(besideStore:)`, ignored its answer, and set
//  `hold = nil` whatever happened — so a removal that failed left the marker
//  standing (the gates, which read the MARKER, kept every round held) under no
//  banner at all, and the next launch came up held again with no explanation.
//
//  RED ON OLD: the fake-store pin's red product keeps the seam and restores the
//  old press (the answer ignored — the run record names where it lives); the
//  real-road pin (a folder the marker cannot leave) needs no seam at all.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-339 — Resume Sync keeps the hold visible when the marker stays", .serialized)
struct VX339ResumeHoldTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-vx339-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// The pin the ticket names: a fake hold store whose clear FAILS. The
    /// banner stays, it says why, nothing resumes and the marker — the gates'
    /// one source — still holds; the next press that removes it resumes once.
    @Test func aClearThatFailsKeepsTheBannerSaysWhyAndResumesNothing() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = dir.appendingPathComponent("variorum.sqlite")
        try LibraryRestoreHold.set(
            besideStore: store, asOf: Date(timeIntervalSince1970: 1_780_000_000), now: Date())
        let removalFails = LockIsolated(true)
        let model = RestoreHoldModel(storeURL: store, clearMarker: { url in
            removalFails.value ? false : LibraryRestoreHold.clear(besideStore: url)
        })
        var resumed = 0
        model.onResume = { resumed += 1 }
        #expect(model.isHeld, "premise: the banner shows")

        await model.resume()
        #expect(model.isHeld, "the banner stays while the marker stands")
        #expect(model.resumeFailure == LibraryOpenCopy.resumeMarkerNotRemoved, "and says why")
        #expect(resumed == 0, "nothing resumes over a standing hold")
        #expect(LibraryRestoreHold.isHeld(besideStore: store), "premise: the fake left the marker")
        #expect(model.markerGate(), "the gates still read the hold")
        #expect(!model.resuming, "the press is over — Resume Sync is pressable again")

        removalFails.setValue(false)
        await model.resume()
        #expect(!model.isHeld, "the banner clears once the marker is gone")
        #expect(model.resumeFailure == nil, "and the failure line with it")
        #expect(resumed == 1, "the catch-up runs once")
        #expect(!LibraryRestoreHold.isHeld(besideStore: store))
        #expect(!model.markerGate())
    }

    /// The same on the REAL road, no seam: the marker sits in a folder it
    /// cannot leave (read-only — `removeItem` fails as on a locked volume or a
    /// permissions fault), so `LibraryRestoreHold.clear` answers false and the
    /// default press must keep the banner.
    @Test func aMarkerThatCannotBeRemovedKeepsTheBannerOnTheRealRoad() async throws {
        let dir = try temporaryDirectory()
        let home = dir.appendingPathComponent("home", isDirectory: true)
        try FileManager.default.createDirectory(at: home, withIntermediateDirectories: true)
        defer {
            try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: home.path)
            try? FileManager.default.removeItem(at: dir)
        }
        let store = home.appendingPathComponent("variorum.sqlite")
        try LibraryRestoreHold.set(besideStore: store, asOf: nil, now: Date())
        try FileManager.default.setAttributes([.posixPermissions: 0o555], ofItemAtPath: home.path)
        #expect(!LibraryRestoreHold.clear(besideStore: store), "premise: the marker cannot be removed here")

        let model = RestoreHoldModel(storeURL: store)
        var resumed = 0
        model.onResume = { resumed += 1 }
        await model.resume()
        #expect(model.isHeld, "the banner stays over the standing marker")
        #expect(resumed == 0)
        #expect(LibraryRestoreHold.isHeld(besideStore: store))
    }
}
