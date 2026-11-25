//
//  BookcaseHintYieldsTests.swift
//  VariorumTests
//
//  VX-409 (the VX-1082 run, batch D; `notes/plans/fixes/vx-1082-nov-24-fixes.md`
//  BATCH D) — **the Bookcase bar's `⌘J today · ⌘N new note` hint yields while
//  a message line shows** (PROVISIONAL A-1082-3: the hint hides while the
//  line speaks; a message that still overflows its room truncates tail-wise,
//  the whole sentence on hover).
//
//  THE MECHANISM (traced in the record, measured windowless): the bar's
//  STATIC layout never overlaps — the line truncates in its room and ends
//  before the hint — so the walk's overlap ("rule 1's receipt overlapped it
//  mid-fade", VX-306 W-7) is the line's animated arrival and leaving beside a
//  hint that stays put. These pins are the rule's GEOMETRY ORACLE on the real
//  Bookcase (`BookcaseRowOracle`, `.global`): while a receipt — or a standing
//  ask — holds the line, the hint is not drawn and the line ends inside the
//  bar; when the line goes, the hint is back. The animated beat itself is the
//  gate walk's capture.
//
//  RED ON OLD (the fix commit's product diff reverse-applied — the DEBUG probe
//  rides the pin commit, so every target compiles): the hint stays drawn
//  beside a speaking line (one expectation in each of the two speaking
//  tests). `theHintIsDrawnAtRest` and the narrow-bar truncation test are
//  GUARDS, green on both trees.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-409 — the Bookcase bar's ⌘J · ⌘N hint yields while a message line shows", .serialized)
struct BookcaseHintYieldsTests {
    /// Her VX-306 walk's receipt (W-7): 450 pt whole at the bar's font.
    static let longReceipt =
        "The key file beside your library was missing. This Mac's sealed copy was put back."

    /// The bar's own horizontal padding (`ShelfView.hintBar`).
    static let barGutter: CGFloat = 28

    /// A reserved key's frame on THIS world's board (session-scoped).
    private static func frame(_ key: String, _ session: AppSession) -> CGRect? {
        #if DEBUG
        BookcaseRowOracle.frame(key, in: session)
        #else
        nil
        #endif
    }

    private func pump() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, turns: Int = 150, until predicate: () -> Bool
    ) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    /// The real Bookcase in a `width` × 640 window, its bar drawn; hands the
    /// body the session and a frame reader for the bar's reserved keys.
    private func onTheBookcase(
        width: CGFloat = 900,
        _ body: (AppSession, _ settle: @MainActor (() -> Bool) async -> Void) async throws -> Void
    ) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "vx409-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            session.status.dismissAfter = .seconds(60)
            _ = try session.operations.createReading(name: "alpha", kind: .book)
            let model = ShelfViewModel(session: session, defaults: defaults)
            BookcaseRowOracle.forgetAll()
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: width, height: 640),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: ShelfView(
                session: session, model: model,
                readings: ReadingsViewModel(session: session),
                onOpen: { _ in }, onTodaysEntry: {}))
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                session.status.clear()
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting) {
                Self.frame(BookcaseRowOracle.hintBarKey, session) != nil
                    && Self.frame(BookcaseRowOracle.hintWordsKey, session) != nil
            }
            await settle(window, hosting, turns: 20) { false }
            try await body(session) { predicate in
                await settle(window, hosting, until: predicate)
                await settle(window, hosting, turns: 20) { false }
            }
        }
        #endif
    }

    /// GUARD (green on both trees): at rest the hint is drawn at the bar's
    /// trailing end, and the idle line takes no width.
    @Test func theHintIsDrawnAtRest() async throws {
        try await onTheBookcase { session, _ in
            let bar = try #require(Self.frame(BookcaseRowOracle.hintBarKey, session))
            let hint = try #require(Self.frame(BookcaseRowOracle.hintWordsKey, session), "the hint is drawn at rest")
            #expect(abs(hint.maxX - (bar.maxX - Self.barGutter)) < 1.5,
                    "at the bar's trailing end (hint \(hint), bar \(bar))")
            if let line = Self.frame(BookcaseRowOracle.hintLineKey, session) {
                #expect(line.width < 0.5, "the idle line takes no width (\(line))")
            }
        }
    }

    /// **RED ON OLD.** Her walk's long receipt on the line: the hint is not
    /// drawn while it speaks, and the line ends inside the bar; when the
    /// receipt goes, the hint is back.
    @Test func whileAReceiptShowsTheHintYieldsAndReturnsAfter() async throws {
        try await onTheBookcase { session, settle in
            #expect(Self.frame(BookcaseRowOracle.hintWordsKey, session) != nil, "premise: the hint is drawn at rest")
            session.status.receipt(Self.longReceipt)
            #expect(session.status.lineItem?.text == Self.longReceipt, "premise: her default quiet style — the line")
            await settle { (Self.frame(BookcaseRowOracle.hintLineKey, session)?.width ?? 0) > 1 }

            #expect(Self.frame(BookcaseRowOracle.hintWordsKey, session) == nil,
                    "the hint yields while the line speaks (drawn at \(String(describing: Self.frame(BookcaseRowOracle.hintWordsKey, session))))")
            let bar = try #require(Self.frame(BookcaseRowOracle.hintBarKey, session))
            let line = try #require(Self.frame(BookcaseRowOracle.hintLineKey, session))
            #expect(line.maxX <= bar.maxX - Self.barGutter + 0.5,
                    "the line ends inside the bar (line \(line), bar \(bar))")

            session.status.clear()
            await settle { Self.frame(BookcaseRowOracle.hintWordsKey, session) != nil }
            #expect(Self.frame(BookcaseRowOracle.hintWordsKey, session) != nil, "the hint is back once the line is gone")
        }
    }

    /// **RED ON OLD.** A STANDING ask (VX-676) holds the line once its toast
    /// is gone — the line speaks, so the hint yields to it too.
    @Test func aStandingAskOnTheLineYieldsTheHintToo() async throws {
        try await onTheBookcase { session, settle in
            session.status.dismissAfter = .milliseconds(50)
            let id = session.status.stand(
                "Claude Code asks to show you “garden plans”.",
                action: .init(label: "Open \u{203A}", perform: {}),
                dismiss: .init(label: "Dismiss", perform: {}))
            await settle { session.status.current == nil && session.status.lineItem != nil }
            #expect(session.status.lineItem?.id == id, "premise: the standing ask holds the line")
            await settle { (Self.frame(BookcaseRowOracle.hintLineKey, session)?.width ?? 0) > 1 }
            #expect(Self.frame(BookcaseRowOracle.hintWordsKey, session) == nil, "the hint yields to the standing ask")
            if let id { session.status.endStanding(id) }
            await settle { Self.frame(BookcaseRowOracle.hintWordsKey, session) != nil }
            #expect(Self.frame(BookcaseRowOracle.hintWordsKey, session) != nil, "the hint is back once the ask ends")
        }
    }

    /// GUARD (green on both trees): in a narrow bar her long receipt
    /// truncates INSIDE the bar — never past its edge (the whole sentence is
    /// the line's hover, `QuietReceiptLine`'s `help`).
    @Test func aLongReceiptInANarrowBarTruncatesInsideIt() async throws {
        try await onTheBookcase(width: 620) { session, settle in
            session.status.receipt(Self.longReceipt)
            await settle { (Self.frame(BookcaseRowOracle.hintLineKey, session)?.width ?? 0) > 1 }
            let bar = try #require(Self.frame(BookcaseRowOracle.hintBarKey, session))
            let line = try #require(Self.frame(BookcaseRowOracle.hintLineKey, session))
            #expect(line.maxX <= bar.maxX - Self.barGutter + 0.5,
                    "the line ends inside the bar (line \(line), bar \(bar))")
            print("[VX-409 narrow bar] bar \(bar) · line \(line)")
            #expect(line.width < 440, "it truncates — the sentence is 450 pt whole (\(line))")
        }
    }
}
