//
//  SampleLibraryDedupeFactsTests.swift
//  VariorumTests
//
//  Pre-13u round, Act 0 (Fable half, R-pre13u-8) — the WIRING pin for the
//  sample-library dedupe's injected facts.
//
//  The repair itself is proven in core (`SampleLibraryDedupeRepairTests`,
//  two in-memory clients vs the fake server) against fixture facts. What
//  core cannot prove is that the facts the APPS actually wire carry the
//  seeder's real identity and the real bundled manifest — the one drift
//  that would leave the shipped repair comparing against nothing. These
//  pins bind `SampleLibrarySeeder.dedupeFacts()` to the seeder's own
//  reserved identities, to the bundled manifest's hashes, and to the one
//  shared hash recipe (`BridgeHash.body`).
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("Sample-library dedupe facts (pre-13u Act 0, R-pre13u-8)")
struct SampleLibraryDedupeFactsTests {
    @Test func theFactsCarryTheSeedersOwnIdentityPredicate() {
        let facts = SampleLibrarySeeder.dedupeFacts()
        #expect(facts.bookName == SampleLibrarySeeder.bookName)
        #expect(facts.tagPath == SampleLibrarySeeder.tagName)
    }

    @Test func theFactsManifestIsTheBundledManifest() throws {
        let facts = SampleLibrarySeeder.dedupeFacts()
        let manifest = try SampleLibrarySeeder.manifest()
        #expect(try facts.loadNoteHashes() == manifest.noteHashes)
        #expect(manifest.noteHashes.count >= 13,
                "front matter plus the twelve stories")
    }

    @Test func theFactsHashIsTheOneSharedRecipe() {
        let facts = SampleLibrarySeeder.dedupeFacts()
        let sample = "To Sherlock Holmes she is always THE woman."
        #expect(facts.hash(sample) == BridgeHash.body(sample))
        // And the recipe agrees with the manifest's own pristine read —
        // the pair travels from one place, so a drift is impossible by
        // construction; this pin is the tripwire if that ever changes.
        let manifest = SampleLibrarySeeder.manifest(
            stories: [.init(title: "t", text: sample)])
        #expect(manifest.isPristine(title: "t", renderedText: sample))
        #expect(manifest.noteHashes["t"] == facts.hash(sample))
    }

    // MARK: - pre-13x 5a: the facts as a LIST — both seeded books

    /// `SyncSession.configure` hands the engine EVERY seeded book's facts,
    /// in seeding order: Sherlock's first (byte-identical to the single
    /// facts above), *Encryption Explained*'s second, carrying ITS reserved
    /// identities and ITS bundled manifest under the one shared recipe.
    ///
    /// 18l-c U6 (re-armed, a changed fact of that unit): the list is the
    /// DEDUPE-COVERED books, no longer `Book.all` — the takemania book is
    /// seeded but deliberately not judged (QUESTIONS #155), so the engine's
    /// list stays exactly these two.
    @Test func theListCarriesBothBooksInSeedingOrder() throws {
        let list = SampleLibrarySeeder.allDedupeFacts()
        #expect(list.count == SampleLibrarySeeder.Book.dedupeCovered.count && list.count == 2)
        #expect(!list.contains { $0.bookName == SampleLibraryJekyllBook.name })
        #expect(list[0].bookName == SampleLibrarySeeder.bookName && list[0].tagPath == SampleLibrarySeeder.tagName)
        #expect(list[1].bookName == SampleLibraryEncryptionBook.name && list[1].tagPath == SampleLibraryEncryptionBook.tagName)
        let manifest = try SampleLibrarySeeder.manifest(for: .encryptionExplained)
        #expect(try list[1].loadNoteHashes() == manifest.noteHashes)
        #expect(manifest.noteHashes.count == 9, "the front matter plus eight chapters")
        let sample = "Your library is one file."
        #expect(list[1].hash(sample) == BridgeHash.body(sample))
        // The two books' names and paths never collide.
        #expect(list[0].bookName != list[1].bookName && list[0].tagPath != list[1].tagPath)
    }
}
