//
//  MobileReferencesTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C3 — the "More info" list (her precision
//  #3: see a note's references, add a URL, open one; file rows honest
//  in neutral words — `file_bookmark` is per-machine by model fact,
//  AppSpec §7). State-transition tests through the view model against a
//  real in-memory store; every act routes through the existing core
//  reference operations.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile references — the More Info list (parity C3)")
struct MobileReferencesTests {
    /// Add-URL end-to-end (the Mac door's semantics mirrored): a bare
    /// host normalizes to https and lands named by its host; rows list
    /// in panel order; an unloadable string refuses in phone words and
    /// mints nothing.
    @Test func addURLNormalizesNamesAndLands() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: "Harbor")
            }.id
            let model = MobileReferencesModel(session: session, postID: postID)
            await model.refresh()
            #expect(model.references.isEmpty)

            #expect(await model.addURL("example.com"))
            #expect(await model.addURL("https://tides.org/tables"))
            let rows = model.references
            #expect(rows.count == 2, "both landed, in panel order")
            #expect(rows[0].kind == .url)
            #expect(rows[0].url == "https://example.com", "the bare host normalized")
            #expect(rows[0].name == "example.com", "named by its host")
            #expect(rows[1].url == "https://tides.org/tables")
            #expect(model.status == nil)

            // An unloadable string refuses and mints nothing.
            #expect(await model.addURL("ht tp://broken url") == false)
            #expect(model.status == MobileReferencesModel.notLoadable("ht tp://broken url"))
            #expect(model.status?.contains("Mac") == false)
            #expect(model.references.count == 2)

            // A blank add is a quiet no-op (the alert's empty field).
            #expect(await model.addURL("   ") == false)
            #expect(model.references.count == 2)
        }
    }

    /// Remove tombstones the row (S2 — never a hard delete), and the
    /// listing follows.
    @Test func removeTombstonesTheRow() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: "Harbor")
            }.id
            let model = MobileReferencesModel(session: session, postID: postID)
            #expect(await model.addURL("example.com"))
            let id = try #require(model.references.first?.id)

            await model.remove(id)
            #expect(model.references.isEmpty)
            let tombstoned = try await db.read { db in
                try Bool.fetchOne(
                    db,
                    sql: "SELECT deleted_at IS NOT NULL FROM reference WHERE id = ?",
                    arguments: [id])
            }
            #expect(tombstoned == true, "a tombstone, not a gone row")
            #expect(model.status == nil)
        }
    }

    /// FIX-C3b (the C3 ladder's false-copy MINOR): the row branch keys
    /// on the STORED KIND — an unopenable URL row (nil url is legal
    /// core: `addReference` validates nothing about the kind/url
    /// pairing, and a synced row can carry it) is its OWN honest state:
    /// its stored text shows, it opens nothing, and it NEVER wears the
    /// file row's sentence. Revert-verified red-on-old: the pre-fix
    /// view branch (openable-else-file-sentence) mirrored into the
    /// brain classifies this row `.file` — the false copy — and this
    /// test fails there while its siblings hold.
    @Test func anUnopenableURLRowNeverWearsTheFileSentence() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Harbor")
                _ = try ops.addReference(
                    to: post.id, kind: .url, name: "somewhere", url: nil)
                _ = try ops.addReference(
                    to: post.id, kind: .url, name: nil, url: "https://example.com")
                _ = try ops.addReference(
                    to: post.id, kind: .file, name: "notes.pdf")
                return post.id
            }
            let model = MobileReferencesModel(session: session, postID: postID)
            await model.refresh()
            let broken = try #require(
                model.references.first { $0.kind == .url && $0.url == nil })
            let good = try #require(
                model.references.first { $0.url == "https://example.com" })
            let file = try #require(model.references.first { $0.kind == .file })

            #expect(MobileReferencesModel.rowState(broken) == .unopenableLink,
                    "a link with nothing to open is its OWN state — never the file row's")
            #expect(MobileReferencesModel.rowTitle(broken) == "somewhere",
                    "the stored text shows")
            #expect(MobileReferencesModel.rowState(good)
                == .opens(URL(string: "https://example.com")!),
                    "a loadable link stays the door it was")
            #expect(MobileReferencesModel.rowState(file) == .file,
                    "the honest sentence's ONLY home is the file kind")
        }
    }

    /// File rows list HONESTLY: they are named, they are not openable
    /// (the bookmark is per-machine by model fact — there is no file
    /// here), and the sentence that says so names NO platform. The chip
    /// and title brains are pinned beside them.
    @Test func fileRowsAreHonestAndNotOpenable() async throws {
        try await withEditorWorld { session, db in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "Harbor")
                // A file reference as sync would deliver it: the row
                // travels, the bookmark bytes do not (serializer-excluded)
                // — so the phone sees name + kind and NO bookmark.
                _ = try ops.addReference(
                    to: post.id, kind: .file, name: "chapter-notes.pdf")
                _ = try ops.addReference(
                    to: post.id, kind: .url, name: nil, url: "https://example.com")
                return post.id
            }
            let model = MobileReferencesModel(session: session, postID: postID)
            await model.refresh()
            let file = try #require(model.references.first { $0.kind == .file })
            let url = try #require(model.references.first { $0.kind == .url })

            #expect(MobileReferencesModel.rowTitle(file) == "chapter-notes.pdf")
            #expect(MobileReferencesModel.openableURL(file) == nil,
                    "a file row opens nothing — there is no file here to open")
            #expect(MobileReferencesModel.openableURL(url)?.absoluteString
                == "https://example.com")
            #expect(MobileReferencesModel.rowTitle(url) == "https://example.com",
                    "an unnamed row falls back to its URL")

            // The honest sentence: what a file row IS, no platform named.
            let note = MobileReferencesModel.fileRowNote
            #expect(note.contains("stays on the device where it was added"))
            #expect(!note.contains("Mac"), "neutral words — never a platform")

            // The chip's words, pinned.
            #expect(MobileReferencesModel.chipLabel(count: 0) == "more info")
            #expect(MobileReferencesModel.chipLabel(count: 2) == "more info · 2")
        }
    }
}
