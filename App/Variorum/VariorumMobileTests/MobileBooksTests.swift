//
//  MobileBooksTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C2 — the books & membership family's
//  shelf-side suite: pin/unpin (the [B1] record's deferred ACT), create
//  book (her feel-round finding + the LK5 expansion's
//  smart-book-from-tags). State-transition tests through the view
//  models against a real in-memory store (the standing discipline);
//  every act routes through existing core operations.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile books — pin/unpin (parity C2)")
struct MobileBookPinTests {
    /// The pin ACT lands as pin-order state and the shelf order follows
    /// (R38's semantics through the core's own `setShelfPinned`); unpin
    /// reverses it exactly. The door's state-mirroring words are pinned
    /// beside the act (the Mac shelf menu's own vocabulary).
    @Test func pinAndUnpinReorderTheShelf() async throws {
        try await withEditorWorld { session, db in
            let (aster, zebra) = try await session.runner.run { ops -> (String, String) in
                (try ops.createReading(name: "Aster", kind: .curated).id,
                 try ops.createReading(name: "Zebra", kind: .curated).id)
            }
            let model = MobileShelfViewModel(session: session)
            let observation = Task { await model.start() }
            defer { observation.cancel() }
            await settle { model.books.count == 2 }
            #expect(model.orderedBooks.map(\.reading.id) == [aster, zebra],
                    "unpinned books order by name")

            await model.setPinned(zebra, pinned: true)
            await settle { model.pins == [zebra] }
            #expect(model.orderedBooks.map(\.reading.id) == [zebra, aster],
                    "the pinned book leads in pin order")
            #expect(try await db.read { db in
                try Queries.shelfPins(db)
            } == [zebra], "the pin is store truth, not view state")

            await model.setPinned(zebra, pinned: false)
            await settle { model.pins.isEmpty }
            #expect(model.orderedBooks.map(\.reading.id) == [aster, zebra],
                    "unpin restores the name order")
            #expect(model.lastError == nil)

            #expect(MobileShelfFaces.pinDoorTitle(pinned: false) == "Pin to Shelf Top")
            #expect(MobileShelfFaces.pinDoorTitle(pinned: true) == "Unpin from Shelf Top")
        }
    }
}

/// The suites' shared settle helper (the MobileShellTests polling shape).
@MainActor
func settle(
    attempts: Int = 2000, _ done: @MainActor () -> Bool
) async {
    for _ in 0..<attempts where !done() {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}
