//
//  VX384ListingFollowRuleTests.swift
//  VariorumTests
//
//  **VX-384 (the VX-348 run, U4) — the held listing's membership rule.** NEW
//  API (fixed-only — removed from the red product); the red-on-old proof is
//  `VX384LibraryFollowsMintsTests.swift`.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-384 — when the held listing's membership moved")
struct VX384ListingFollowRuleTests {
    /// **The membership rule** (new API — fixed-only): the first delivery is
    /// the baseline; a re-order moves nothing; a note coming or going does.
    @Test func onlyAChangeInWhichNotesMovesTheListing() async throws {
        #expect(!LibraryListingFollow.moved(previous: nil, current: ["a", "b"]), "the first delivery is the baseline")
        #expect(!LibraryListingFollow.moved(previous: ["a", "b"], current: ["b", "a"]), "order is not membership")
        #expect(LibraryListingFollow.moved(previous: ["a", "b"], current: ["a", "b", "c"]), "a note came")
        #expect(LibraryListingFollow.moved(previous: ["a", "b"], current: ["a"]), "a note went")

        let db = try AppDatabase.inMemory()
        withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let library = LibraryViewModel(session: AppSession(database: db))
            func item(_ id: String) -> Queries.TimelineItem {
                Queries.TimelineItem(postID: id, title: id, entryDate: nil, stamp: "2026-07-01T00:00:00.000Z")
            }
            library.adoptHeldMembership([item("a"), item("b")])
            #expect(library.listingMoves == 0, "the baseline")
            library.adoptHeldMembership([item("b"), item("a")])
            #expect(library.listingMoves == 0, "typing re-orders: nothing moved")
            library.adoptHeldMembership([item("c"), item("b"), item("a")])
            #expect(library.listingMoves == 1, "a mint moved it")
            library.adoptHeldMembership([item("c"), item("a")])
            #expect(library.listingMoves == 2, "a removal moved it")
        }
    }
}
