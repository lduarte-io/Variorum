//
//  MobileEmptyStoreTests.swift
//  VariorumMobileTests
//
//  Pre-13u round, Act 0 — the empty-state copy that rides R-pre13u-1.
//
//  Seeding on first write means a fresh install genuinely holds nothing,
//  and the recorded cost of her ruling was *"'empty app' on first open —
//  which may read as broken without a little empty-state copy"*. These
//  pins hold the two things that make the copy do its job: it names BOTH
//  roads (start one · sign in), and the door it names is DERIVED from the
//  door rather than retyped beside it.
//

import Testing
@testable import VariorumMobile

@MainActor
@Suite("What a fresh install says before her first write")
struct MobileEmptyStoreTests {

    /// The door name is derived, never a second copy of the same string —
    /// so renaming the door cannot leave a sentence pointing at a button
    /// that no longer says that (the K5 naming discipline applied to copy).
    @Test func theEmptyLibraryNamesTheRealDoor() {
        #expect(MobileEmptyStoreCopy.noNotesDoor
            .contains(MobileNewNoteDoor.doorTitle))
    }

    /// **BOTH roads, on both empty surfaces.** A fresh install has exactly
    /// two kinds of owner — a new writer and a returning one on a new
    /// phone — and naming only the first is what makes an empty screen read
    /// as "my writing is gone" instead of "nothing here yet".
    ///
    /// *Red on the old behaviour:* the Library had no empty state at all
    /// (a path line, a search field, a filter row and nothing else), and
    /// no surface anywhere named the sign-in road.
    @Test func bothRoadsAreNamed() {
        #expect(!MobileEmptyStoreCopy.noNotes.isEmpty)
        #expect(!MobileEmptyStoreCopy.noBooks.isEmpty)
        // The returning-owner road, and it points where the door actually
        // is: Settings ▸ Sync holds `SyncStatusRow`, which presents the
        // account sheet.
        #expect(MobileEmptyStoreCopy.signIn.contains("Settings"))
        #expect(MobileEmptyStoreCopy.signIn.contains("Sync"))
    }
}
