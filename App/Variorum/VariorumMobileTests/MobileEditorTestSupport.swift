//
//  MobileEditorTestSupport.swift
//  VariorumMobileTests
//
//  Mobile Stage 1, batch 1 — the Write-true editor suite's harness. The
//  Phase 8 `withMobileWorld` shape (deterministic dependencies over an
//  in-memory store + a real AppSession), reused for the editor tests; the
//  file-private original stays untouched in VariorumMobileTests.swift
//  (`SeededGenerator` there is internal and is reused, not redeclared).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// A fresh in-memory world with deterministic dependencies and a real
/// AppSession — the editor suite's twin of Phase 8's harness.
@MainActor
func withEditorWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    // Batch 3: every world runs in the DEFAULT voice, deterministically —
    // LK2's stored preference must never leak simulator state into byte/
    // attribute expectations (voice-switch tests set and restore their
    // own).
    MobileEditorStyle.voice = .terminal
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

/// An editor model with both clocks disabled (tests flush and mint
/// explicitly, deterministically) attached to a bare `NSTextStorage`
/// through the VM's storage seam — the whole brain runs headless.
@MainActor
func makeEditor(
    _ session: AppSession, postID: String
) -> (model: MobileEditorViewModel, storage: NSTextStorage) {
    let model = MobileEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
    model.tailIdleSleep = { _ in throw CancellationError() }
    let storage = NSTextStorage()
    model.attach(storage: storage)
    return (model, storage)
}

/// Simulates one policed user edit the way iOS delivers it: the delegate
/// gate first, then the storage mutation (didProcessEditing reports it to
/// the model). The inserted characters deliberately carry NO custom
/// attributes — the Stage 0 memo's measured iOS truth (`typingAttributes`
/// carry only font/color; EVERY insertion path strips custom keys), so
/// every simulated keystroke exercises the re-stamp obligation exactly as
/// the real keyboard does.
@MainActor
@discardableResult
func typeEdit(
    _ model: MobileEditorViewModel, _ storage: NSTextStorage,
    range: NSRange, replacement: String, isPaste: Bool = false
) -> Bool {
    guard model.shouldChangeText(in: range, replacement: replacement, isPaste: isPaste) else {
        return false
    }
    storage.replaceCharacters(
        in: range,
        with: NSAttributedString(
            string: replacement,
            attributes: [.font: MobileEditorStyle.baseFont]))
    return true
}

/// Appends at the exact document end (the common typing position).
@MainActor
@discardableResult
func typeAtEnd(
    _ model: MobileEditorViewModel, _ storage: NSTextStorage,
    _ replacement: String, isPaste: Bool = false
) -> Bool {
    typeEdit(
        model, storage,
        range: NSRange(location: storage.length, length: 0),
        replacement: replacement, isPaste: isPaste)
}

/// One variant's stored working text.
@MainActor
func storedText(_ db: AppDatabase, variantID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT working_text FROM variant WHERE id = ?",
            arguments: [variantID])
    }
}

/// All live variant texts in placement order (the post's stored bytes).
@MainActor
func storedBlockTexts(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(db, sql: """
            SELECT v.working_text FROM container_block cb
            JOIN block b ON b.id = cb.block_id
            JOIN variant v ON v.id = COALESCE(cb.chosen_variant_id, b.default_variant_id)
            WHERE cb.container_id = ? AND cb.deleted_at IS NULL
            ORDER BY cb.position, cb.id
            """, arguments: [postID])
    }
}
