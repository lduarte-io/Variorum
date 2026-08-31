//
//  SampleLibraryManifestTests.swift
//  VariorumMobileTests
//
//  Pre-13u round, Act 0 — THE PRISTINE PREDICATE (R-pre13u-8).
//
//  The manifest exists for the dedupe repair that follows this act: once
//  the PHONE can seed the sample library too, two devices can each
//  correctly decide "no sample library exists yet" and both seed, and the
//  pair meets under sync. Her ruled resolution turns on one fact per note
//  — *is this copy still exactly what shipped?* — so the manifest's whole
//  job is to answer that, and these pins are what make the answer
//  trustworthy enough to retire a book on.
//
//  ── WHY THE PINS LIVE IN THE MOBILE TARGET ────────────────────────────
//  `SampleLibrarySeeder` was hoisted to `Shared/` this act, so it compiles
//  into BOTH apps from ONE file — pinning it twice would be the
//  forked-brains sin the hoist exists to avoid. It is pinned here rather
//  than Mac-side for two reasons: the manifest is the phone's own story
//  (the Mac never needed a pristine predicate, having been the only
//  seeder), and the Mac suite deliberately rides this hoist UNMODIFIED —
//  a zero-test-edit Mac suite is the evidence that an address moved and
//  behaviour did not.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
private final class Mark {
    var value = false
    var load: () -> Bool { { [self] in value } }
    var save: (Bool) -> Void { { [self] in value = $0 } }
}

@Suite("The sample library's manifest — the pristine predicate")
struct SampleLibraryManifestTests {

    /// **THE LOAD-BEARING PIN.** The manifest hashes the BUNDLED SOURCE;
    /// the repair will hash what the STORE holds. If those two disagree by
    /// so much as a newline, every copy reads as edited, the rule falls
    /// through to "both edited → both survive", and the dedupe silently
    /// stops deduping.
    ///
    /// So this drives the real seed against the real 562 KB resource and
    /// compares note by note, exactly as the engine will:
    /// `BridgeHash.body(Queries.renderedText(...))`. (`importPost`'s bulk
    /// segmentation documents a byte-for-byte round trip through
    /// `renderedText`; this is what holds that documentation to it.)
    @Test func theManifestMatchesWhatTheSeedActuallyStores() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let manifest = try SampleLibrarySeeder.manifest()

            let verdicts = try await db.read { db -> [(String, Bool)] in
                try Queries.assembleReading(db, readingID: bookID).map { entry in
                    let title = entry.title ?? ""
                    let text = try Queries.renderedText(db, containerID: entry.postID)
                    return (title, manifest.isPristine(title: title, renderedText: text))
                }
            }
            #expect(verdicts.count == 13, "twelve adventures plus the attribution")
            for (title, pristine) in verdicts {
                #expect(pristine, "a freshly seeded \"\(title)\" must read as pristine")
            }
        }
    }

    /// The other direction, and the one her rule protects: a note she has
    /// TOUCHED is not pristine, so the repair keeps it and retires the
    /// untouched copy instead. One character is enough — an edited copy is
    /// never silently retired.
    @Test func oneEditedCharacterEndsPristine() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let bookID, _) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let manifest = try SampleLibrarySeeder.manifest()

            let target = try await db.read { db -> (post: String, variant: String, text: String) in
                let entry = try #require(
                    Queries.assembleReading(db, readingID: bookID)
                        .first { $0.title == "A Scandal in Bohemia" })
                let slot = try #require(
                    Queries.renderPost(db, containerID: entry.postID).first)
                return (entry.postID, try #require(slot.variantID), slot.text ?? "")
            }
            try await session.runner.run { ops in
                try ops.autosave(
                    target.variant, text: target.text + "!", charDelta: 1)
            }

            let after = try await db.read { db in
                try Queries.renderedText(db, containerID: target.post)
            }
            #expect(!manifest.isPristine(
                title: "A Scandal in Bohemia", renderedText: after),
                "her writing is what the rule exists to keep")
        }
    }

    /// A note the manifest does not know is NEVER pristine — a note she
    /// ADDED to the book is her own, and the rule must not treat "I have
    /// no hash for this" as "this is untouched shipped content".
    @Test func aTitleTheManifestDoesNotKnowIsNeverPristine() throws {
        let manifest = SampleLibrarySeeder.manifest(stories: [
            .init(title: "A Scandal in Bohemia", text: "Body.")
        ])
        #expect(manifest.isPristine(
            title: "A Scandal in Bohemia", renderedText: "Body."))
        #expect(!manifest.isPristine(title: "My own note", renderedText: "Body."),
                "an unknown title is hers, whatever it happens to say")
    }

    /// The identity half the repair also needs: the manifest carries the
    /// reserved book name and tag path, so the engine can recognise a copy
    /// without re-deriving `discover`'s rule from memory.
    @Test func theManifestCarriesTheReservedIdentities() throws {
        let manifest = try SampleLibrarySeeder.manifest()
        #expect(manifest.bookName == SampleLibrarySeeder.bookName)
        #expect(manifest.tagName == SampleLibrarySeeder.tagName)
        #expect(manifest.titles.contains(SampleLibrarySeeder.frontMatterTitle))
        #expect(manifest.titles.count == 13)
    }

    /// The recipe is the CORE's, not a second one: the engine side lives in
    /// `Sources/VariorumCore/Sync/`, which cannot see app-target code at
    /// all, so both halves must name one public function. Pinned so a
    /// well-meaning "let's use our own hash here" reds instead of quietly
    /// making the two sides disagree.
    @Test func theHashIsTheCoresOwnRecipe() throws {
        let manifest = SampleLibrarySeeder.manifest(stories: [
            .init(title: "Only", text: "The text.")
        ])
        #expect(manifest.noteHashes["Only"] == BridgeHash.body("The text."))
    }
}
