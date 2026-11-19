//
//  VM63MacWingBrainsHoistPinTests.swift
//  VariorumTests
//
//  **VM-63 (the VM-55 run, "Wings underneath", batch 3) — the Mac's wing brains
//  speak exactly as before after the hoist to shared code.** The moved code is
//  byte for byte but for its seams, and the existing Mac wing suites drive
//  every act through them (the batch record lists them by type). One seam
//  changed text on the Mac's path and the suites cannot tell its two possible
//  roads apart, so it is pinned here: the refusal WORDS. `WingsModel` used to
//  call `OpsRefusalCopy.message(for:)` itself; now it speaks the words its
//  platform hands it, and the Mac's `init(session:)` hands it exactly that
//  function. The shared table's other road — the phone's
//  `sentence(for:roads:)`, which ends in one plain fallback — agrees with it
//  on every worded case (the only refusal the wing suites provoke), so only
//  the cases where the two roads part can show which one is wired: a Mac-only
//  arm, and an error no table words.
//
//  And the shape that keeps a brain one brain (MobileSoul §3; review focus 7):
//  no hoisted file forks by platform or imports a face framework.
//
//  **How a regression trips it:** a Mac construction that handed the brain the
//  phone's road — or any words but the Mac's — reds the first pin on the
//  Mac-only arms and the undescribed error; an `#if os(` or a face import in a
//  hoisted file reds the second.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VM-63 — the Mac's wing brains speak as before after the hoist to shared code")
struct VM63MacWingBrainsHoistPinTests {
    private struct NotAnOperationError: Error {}

    /// The Mac's `WingsModel(session:)` speaks the Mac's refusal words —
    /// `OpsRefusalCopy.message(for:)` — on the cases where the shared table's
    /// phone road would say something else.
    @Test func theMacsWingsBrainSpeaksTheMacsRefusalWords() async throws {
        let db = try AppDatabase.inMemory()
        let wings = await withDependencies {
            $0.database = db
        } operation: { @MainActor in
            WingsModel(session: AppSession(database: db))
        }
        let parting: [Error] = [
            // The Mac's own arms (`Registry/OpsRefusalCopy.swift`'s `macWords`).
            OperationError.lockedReading(id: "book"),
            OperationError.wingMoveChangedSince(postID: "note"),
            // No table words it: the Mac describes it; the phone's road would
            // say its plain fallback.
            NotAnOperationError(),
        ]
        for error in parting {
            #expect(wings.refusalWords(error) == OpsRefusalCopy.message(for: error), "\(error)")
            #expect(wings.refusalWords(error) != OpsRefusalCopy.sentence(for: error, roads: .mac),
                    "the case parts the two roads, so it shows which one is wired: \(error)")
        }
        // A worded case: both roads agree, and the brain says it.
        let worded = OperationError.duplicateWingName(name: "Home")
        #expect(wings.refusalWords(worded) == OpsRefusalCopy.message(for: worded))
    }

    /// No hoisted brain forks by platform or imports a face framework — the
    /// brain is one brain on both platforms (the phone target compiling them
    /// is the other half of this guard).
    @Test func theHoistedBrainsCarryNoPlatformForkAndNoFace() throws {
        let shared = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Shared")
        let forbidden = ["#if os(", "import AppKit", "import UIKit", "import SwiftUI"]
        var hits: [String] = []
        for name in VM61MacStatusSeamPinTests.hoistedMacBrains {
            let file = shared.appendingPathComponent(name)
            let text = try String(contentsOf: file, encoding: .utf8)
            for (number, line) in text.components(separatedBy: "\n").enumerated() {
                guard !line.trimmingCharacters(in: .whitespaces).hasPrefix("//") else { continue }
                for word in forbidden where line.contains(word) {
                    hits.append("\(name):\(number + 1): \(word)")
                }
            }
        }
        #expect(hits.isEmpty, "a hoisted brain forked or took a face: \(hits)")
    }
}
