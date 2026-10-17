//
//  U4NoticeTests.swift
//  VariorumCoreTests — VX-378 U4 resumption, piece 3: RULE 21'S NOTICE (her
//  ruling at the U4 stop, 2026-10-17, superseding U2's refusal): "we also do
//  not need to protect them from hand copying an old library over - they have
//  to just remember that at that point"; "I think we can have a popup that it's
//  probably an issue without banning it from working". When the library in the
//  live place is not the one this Mac last opened, the app OPENS it, says so
//  ONCE — "This is an older copy of your library, from <date>" / "This is a
//  different library than the one this Mac last had open" — and then remembers
//  this one. The open itself writes nothing; the memory follows at the open's
//  repairs. The pins read the notice by reflection (the API both trees share —
//  the tree before the piece refuses the open, and has no notice).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// The notice an unlocked library carries, by reflection (nil: none, or no
/// such field — the tree before rule 21's notice).
func noticeText(_ library: UnlockedLibrary) -> String? {
    guard let child = Mirror(reflecting: library).children.first(where: { $0.label == "notice" }) else { return nil }
    let text = String(describing: child.value)
    return text == "nil" ? nil : text
}

@Suite("VX-378 U4 — rule 21's notice: the open goes on, says so once, then remembers this library")
struct U4NoticeTests {
    /// A library file replayed into the live place (the key file beside reaches
    /// it through its history): it opens, says it is an older copy, writes
    /// nothing itself; the memory then follows, and the next open says nothing.
    @Test func aReplayedLibraryFileOpensAndSaysItIsAnOlderCopy() async throws {
        let fixture = try EX(.standard)
        let k0 = fixture.key
        let older = fixture.world.live!
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        let k1 = library.key
        fixture.world.live = older
        fixture.world.writes = []
        let e2 = fixture.executor()
        var opened = try e2.unlock(with: k0, alsoInHand: [k1])
        #expect(noticeText(opened)?.contains("olderCopy") == true, "\(String(describing: noticeText(opened)))")
        #expect(fixture.world.writes.isEmpty, "the open itself wrote \(fixture.world.writes)")
        _ = try e2.runRepairs([.refreshMemory], on: &opened)
        #expect(fixture.memoryValue(k0)?.currentFingerprint == PF.fp(k0), "what this Mac remembers didn't follow the library")
        let again = try fixture.executor().unlock(with: k0, alsoInHand: [k1])
        #expect(noticeText(again) == nil, "it said so twice")
    }

    /// A backup pair copied into the live place by hand — the older library
    /// AND its key file: it opens with the older copy's notice.
    @Test func aBackupPairCopiedInByHandOpensAndSaysItIsAnOlderCopy() async throws {
        let fixture = try EX(.standard)
        let k0 = fixture.key
        let olderLibrary = fixture.world.live!, olderFile = fixture.world.liveKeyFile
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .alwaysAsk)
        fixture.world.live = olderLibrary
        fixture.world.liveKeyFile = olderFile
        fixture.world.writes = []
        let opened = try fixture.executor().unlock(with: k0)
        #expect(noticeText(opened)?.contains("olderCopy") == true, "\(String(describing: noticeText(opened)))")
        #expect(fixture.world.writes.isEmpty && fixture.world.liveKeyFile == olderFile)
    }

    /// Another library in the live place while this Mac remembers its own: it
    /// opens, says it is a different library; then this Mac remembers that one
    /// — and only that one (rule 21: one library).
    @Test func anotherLibraryInTheLivePlaceOpensAndSaysItIsADifferentLibrary() async throws {
        let mine = try EX(.castle)
        let theirs = try EX(.standard)
        mine.world.live = theirs.world.live
        mine.world.liveKeyFile = theirs.world.liveKeyFile
        mine.world.writes = []
        let executor = mine.executor()
        var opened = try executor.unlock(with: theirs.key)
        #expect(noticeText(opened)?.contains("differentLibrary") == true, "\(String(describing: noticeText(opened)))")
        #expect(mine.world.writes.isEmpty)
        _ = try executor.runRepairs([.refreshMemory], on: &opened)
        #expect(Set(mine.world.memories.keys) == [theirs.libraryID], "this Mac remembers \(mine.world.memories.keys.count) libraries")
    }

    /// A key file replayed beside the library it doesn't open: the library is
    /// the one this Mac remembers — it opens with no notice (the key file is
    /// the offer's, `U4KeyFileOfferTests`).
    @Test func aReplayedKeyFileOpensWithNoNotice() async throws {
        let fixture = try EX(.standard)
        let olderFile = try #require(fixture.world.liveKeyFile)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        fixture.world.liveKeyFile = olderFile
        fixture.world.writes = []
        let opened = try fixture.executor().unlock(with: library.key)
        #expect(noticeText(opened) == nil)
        #expect(fixture.world.writes.isEmpty && fixture.world.liveKeyFile == olderFile, "the stray key file was touched")
    }

    /// PROVISIONAL P-VX378-U4-5: a library that MOVED ON past what this Mac
    /// remembers (a memory item from an earlier moment — its own key file's
    /// history carries the remembered key) is this library, not an older copy:
    /// no notice; the memory follows.
    @Test func aLibraryThatMovedOnPastWhatThisMacRemembersSaysNothing() async throws {
        let fixture = try EX(.standard)
        let earlierMemory = try #require(fixture.world.memories[fixture.libraryID])
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        fixture.world.memories[fixture.libraryID] = earlierMemory
        let e2 = fixture.executor()
        var opened = try e2.unlock(with: library.key)
        #expect(noticeText(opened) == nil)
        _ = try e2.runRepairs([.refreshMemory], on: &opened)
        #expect(fixture.memoryValue(library.key)?.currentFingerprint == PF.fp(library.key))
    }

    /// Her strings, verbatim, as the model's values — and the date written in.
    @Test func herWordsAreTheModelsValues() {
        #expect(LibraryNotice.olderCopyWords == "This is an older copy of your library, from <date>")
        #expect(LibraryNotice.differentLibraryWords == "This is a different library than the one this Mac last had open")
        let day = PF.day(3)
        let notice = LibraryNotice(kind: .olderCopy(date: day))
        #expect(notice.words == LibraryNotice.olderCopyWords)
        #expect(notice.sentence { _ in "August 3" } == "This is an older copy of your library, from August 3")
        #expect(LibraryNotice(kind: .differentLibrary).sentence { _ in "x" } == LibraryNotice.differentLibraryWords)
    }

    /// The older copy's notice carries the copy's own date (its record's).
    @Test func theOlderCopysNoticeCarriesItsDate() async throws {
        let fixture = try EX(.standard)
        let k0 = fixture.key
        let older = fixture.world.live!
        let olderDate = try #require(older.record?.changedAt)
        let executor = fixture.executor()
        var library = try fixture.unlocked(executor)
        fixture.world.clockTime = fixture.world.clockTime.addingTimeInterval(86_400 * 5)
        _ = try await executor.useCastle(&library, typed: fixture.typed, gate: .touchID)
        fixture.world.live = older
        let opened = try fixture.executor().unlock(with: k0, alsoInHand: [library.key])
        #expect(opened.notice?.kind == .olderCopy(date: olderDate))
    }

    /// `assess` reports the notice until what this Mac remembers has followed
    /// the library — owing the memory's follow, closing no door.
    @Test func assessReportsTheNoticeUntilTheMemoryFollows() throws {
        var world = try AWorld(.castle)
        var memory = world.agreeingMemory
        memory.currentFingerprint = PF.fp(StoreKey.mint())
        world.memory = memory
        world.notice = LibraryNotice(kind: .olderCopy(date: PF.day(2)))
        let assessed = try world.assessed()
        #expect(assessed.faults.contains(.libraryNotice(LibraryNotice(kind: .olderCopy(date: PF.day(2))))), "\(assessed.faults)")
        #expect(assessed.repairs.contains(.refreshMemory))
        #expect(assessed.doors.values.contains { $0.isOpen }, "a door closed over the notice")
        world.memory = nil
        world.memoryAbsent = false
        let followed = try world.assessed()
        #expect(!followed.faults.contains { if case .libraryNotice = $0 { return true } else { return false } })
    }
}
