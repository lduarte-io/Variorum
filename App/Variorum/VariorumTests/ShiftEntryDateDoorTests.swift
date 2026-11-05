//
//  ShiftEntryDateDoorTests.swift
//  VariorumTests
//
//  VX-587 (the VX-805 run, Unit A; R-805-3 — "chord + menu act") — "Shift date
//  a day earlier": its declaration (P-1), its gate (P-2: a dated note, the
//  mounted note's fact for the routed doors), the router's fact, ⌘K's listing,
//  and the one act's receipt and refusal. The op's own state transition is the
//  core's `ShiftEntryDateTests`. The chord is an in-batch design fork — these
//  pins hold the PRE-CHORD declaration (no `.menuBar`, no label) and flip when
//  her ruling wires it.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withShiftWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 587))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("VX-587 — Shift date a day earlier", .serialized)
struct ShiftEntryDateDoorTests {
    /// Declared once: her words for the verb, note scope, both `note ▾` menus
    /// and ⌘K — no chord yet (the design fork waits on her ruling).
    @Test func theActIsDeclaredOnTheBarsAndThePalette() {
        let door = CapabilityRegistry.capability(.shiftEntryDateEarlier)
        #expect(door.verb == "Shift date a day earlier", "her words (R-805-3)")
        #expect(door.scope == .post)
        #expect(door.doors == [.bottomBar, .palette], "the chord is wired only at the ruling")
        #expect(door.shortcutLabel == nil)
        #expect(door.takesAccess == .native)
        #expect(!door.unavailableNote.isEmpty)
        #expect(ShellActions.paletteActs.contains(.shiftEntryDateEarlier))
        for bar in [CommitBar.renderedCapabilities, TakesBottomBar.renderedCapabilities] {
            #expect(bar.contains(.shiftEntryDateEarlier), "both bars (R6-2)")
        }
    }

    /// The gate: it acts where a note's detail is mounted AND that note has a
    /// date, in every mode; with no date, or no detail, it is no door.
    @Test func itActsOnlyOnAMountedDatedNote() {
        func availability(_ context: CapabilityContext) -> Capability.Availability {
            CapabilityRegistry.availability(.shiftEntryDateEarlier, in: context)
        }
        #expect(availability(CapabilityContext(mode: .write)) == .unavailable, "an undated note")
        #expect(availability(CapabilityContext(mode: nil, noteHasEntryDate: true)) == .unavailable,
                "no note mounted")
        for mode in PostMode.allCases {
            #expect(availability(CapabilityContext(mode: mode, noteHasEntryDate: true)) == .act,
                    "\(mode): a mounted, dated note")
        }
    }

    /// The bars' row rule: a valid stored day — never an empty or malformed one.
    @Test func theDoorShowsOnlyOnADatedNote() {
        #expect(EntryDateShift.doorShows(entryDate: "2026-11-05"))
        #expect(!EntryDateShift.doorShows(entryDate: nil))
        #expect(!EntryDateShift.doorShows(entryDate: ""))
        #expect(!EntryDateShift.doorShows(entryDate: "Nov 5"))
    }

    /// The router's fact is the MOUNTED note's date and only its: another
    /// note's report is dropped, a new arrival clears it, the gate follows.
    @Test func theRoutersDateFactBelongsToTheMountedNote() {
        let router = CommandRouter()
        let token = router.registerDetail(postID: "note-a", mode: .write, applyMode: { _ in })
        router.noteEntryDate("2026-11-05", postID: "note-b")
        #expect(router.activeNoteEntryDate == nil, "another note's report is dropped")
        #expect(!router.isEnabled(.shiftEntryDateEarlier))
        router.noteEntryDate("2026-11-05", postID: "note-a")
        #expect(router.currentContext().noteHasEntryDate)
        #expect(router.isEnabled(.shiftEntryDateEarlier))
        router.noteEntryDate(nil, postID: "note-a")
        #expect(!router.isEnabled(.shiftEntryDateEarlier), "Clear Date takes the door away")

        router.noteEntryDate("2026-11-05", postID: "note-a")
        _ = router.registerDetail(postID: "note-c", mode: .takes, applyMode: { _ in })
        #expect(router.activeNoteEntryDate == nil, "the arriving note reports its own")
        router.noteEntryDate("2026-01-01", postID: "note-c")
        router.unregisterDetail(token)  // a stale teardown changes nothing
        #expect(router.activeNoteEntryDate == "2026-01-01")
    }

    /// ⌘K lists the row only while the mounted note has a date (P-2); the
    /// every-row listing (the registry walk's) carries it.
    @Test func thePaletteListsTheRowOnlyOnADatedNote() async throws {
        try await withShiftWorld { session, _ in
            let actions = ShellActions(session: session, shell: ShellRouter())
            let verb = CapabilityRegistry.capability(.shiftEntryDateEarlier).verb
            let facts = WingPaletteDoors.Facts(focus: .note("note-a"), wingCount: 1)
            #expect(!actions.paletteEntries(listing: facts, noteHasEntryDate: false)
                .map(\.title).contains(verb))
            #expect(actions.paletteEntries(listing: facts, noteHasEntryDate: true)
                .map(\.title).contains(verb))
            #expect(actions.paletteEntries(listing: nil).map(\.title).contains(verb))
        }
    }

    /// THE ACT: one day earlier in the store, the receipt naming the new date;
    /// a second press goes one more; an undated note speaks the registry's
    /// note and writes nothing.
    @Test func theActShiftsAndTheReceiptNamesTheNewDate() async throws {
        try await withShiftWorld { session, db in
            let (dated, undated) = try await session.runner.run { ops in
                (try ops.createPost(title: "late", entryDate: "2026-03-01").id,
                 try ops.createPost(title: "plain").id)
            }
            func day(_ id: String) async throws -> String? {
                try await db.read { db in
                    try String.fetchOne(db, sql: "SELECT entry_date FROM container WHERE id = ?",
                                        arguments: [id])
                }
            }

            await EntryDateShift.shiftEarlier(postID: dated, session: session)
            #expect(try await day(dated) == "2026-02-28")
            #expect(session.status.spoken?.text == "Now dated 2026-02-28.")
            #expect(session.status.spoken?.kind == .receipt)

            await EntryDateShift.shiftEarlier(postID: dated, session: session)
            #expect(try await day(dated) == "2026-02-27")

            await EntryDateShift.shiftEarlier(postID: undated, session: session)
            #expect(try await day(undated) == nil, "nothing written")
            #expect(session.status.spoken?.text
                    == CapabilityRegistry.capability(.shiftEntryDateEarlier).unavailableNote)
            #expect(session.status.spoken?.kind == .refusal)
        }
    }
}
