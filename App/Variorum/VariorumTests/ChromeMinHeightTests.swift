//
//  ChromeMinHeightTests.swift
//  VariorumTests
//
//  The Sitting 9 wedged-window pin (2026-07-19, the taste-checkpoint fix
//  round). Root cause, traced live: the R94 inline-cause block renders in
//  NON-SCROLLING window chrome (the sidebar's status footer), and the
//  window's minimum-size computation probes content at near-zero width.
//  A `fixedSize(horizontal: false, vertical: true)` text with NO line
//  limit measures one-character-per-line under that probe — the ~140-char
//  auth guidance measured ~1693 pt — and that height becomes the WINDOW's
//  minimum: taller than the screen, pinned to the menu bar, undraggable,
//  every bottom bar rendered below the screen edge. (The previously
//  suspected "persisted oversized frame" was this bug's symptom: the
//  frame autosave recorded the inflated minimum.)
//
//  The fix is the line limits on ErrorCauseNote. This pin measures the
//  REAL component under the same near-zero-width probe the window uses;
//  it is red on the pre-fix modifiers (≈1693 pt) and green on the shipped
//  ones (a few caption lines).
//

import AppKit
import Dependencies
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
struct ChromeMinHeightTests {

    /// Her actual bridge failure from the live wedge — auth-shaped, so the
    /// guidance line renders above the verbatim error (the tall path).
    private static let authShapedError =
        "endpointFailure(status: 400, body: \"{\\\"code\\\":400,"
        + "\\\"error_code\\\":\\\"refresh_token_not_found\\\","
        + "\\\"msg\\\":\\\"Invalid Refresh Token: Refresh Token Not Found\\\"}\")"

    @Test func chromeNoticeNearZeroWidthProbeStaysBounded() {
        // Batch 12 (the Lenses recurrence): the boards' status/footer texts
        // are the same hazard class as ErrorCauseNote — ChromeNotice is
        // their one shared shape, and its line limit is what bounds the
        // window's near-zero-width minimum-size probe. A ~200-char notice
        // with the limit reverted measures >1000 pt here.
        let longStatus = String(
            repeating: "Saved the current choices as a lens named after today. ", count: 4)
        let host = NSHostingController(
            rootView: ChromeNotice(
                tokens: .terminalLight, text: longStatus))
        let probed = host.sizeThatFits(in: NSSize(width: 1, height: 0))
        #expect(probed.height < 400)
    }

    @Test func causeNoteNearZeroWidthProbeStaysBounded() {
        let host = NSHostingController(
            rootView: VStack(alignment: .leading, spacing: 2) {
                ErrorCauseNote(error: Self.authShapedError)
            }
            .font(.caption))
        let probed = host.sizeThatFits(in: NSSize(width: 1, height: 0))
        // Pre-fix this measured ≈1693 pt (one character per line × ~140).
        // Bounded = the guidance's 6 lines + the error's 4, caption-sized,
        // with generous headroom for line-height drift across OS releases.
        #expect(probed.height < 400)
    }

    /// Ladder R1-6 — HOLLOW, and this pin is the measurement: the finding
    /// read the Block History pane's explainer (an unlimited `fixedSize`
    /// text OUTSIDE the pane's scroll view, sheet-hosted too) as the b6dae25
    /// wedged-window class. The window's own near-zero-width probe over the
    /// pane and over the tray answers **280 pt** — with the texts where they
    /// are AND with them moved inside the scroll views (the behavioral
    /// revert of the move): both panes pin `minWidth` (300 / 280) and
    /// `minHeight: 280`, so the probe never measures the text at one
    /// character per line. Kept as the class's guard: a pane that drops its
    /// width floor turns this red.
    /// NOT red on old — the finding was dismissed on this evidence.
    @Test func sheetHostedRecoveryPanesNearZeroWidthProbeStayBounded() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 6))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "a note")
            let block = try session.operations.newBlock(in: post.id, text: "A block.").block.id
            let pane = NSHostingController(
                rootView: BlockHistoryPane(
                    session: session,
                    request: BlockHistoryRequest(postID: post.id, blockID: block),
                    onJump: { _ in })
                    .environment(ThemeStore(session: session)))
            let probedPane = pane.sizeThatFits(in: NSSize(width: 1, height: 0))
            print("[ladder R1-6] the sheet-hosted Block History pane's near-zero-width probe: \(probedPane.height) pt")
            #expect(probedPane.height < 400, "the pane's minimum height stays bounded: \(probedPane.height)")

            let tray = NSHostingController(
                rootView: TrayPanel(session: session, postID: post.id)
                    .environment(ThemeStore(session: session)))
            let probedTray = tray.sizeThatFits(in: NSSize(width: 1, height: 0))
            print("[ladder R1-6] the tray's near-zero-width probe: \(probedTray.height) pt")
            #expect(probedTray.height < 400, "the tray's minimum height stays bounded: \(probedTray.height)")
        }
    }

    /// The block must still be a REAL multi-line rendering at the footer's
    /// actual width — the line limits bound the pathological probe, never
    /// the ordinary wrap (R94: the cause renders inline, readable).
    @Test func causeNoteRendersWrappedAtFooterWidth() {
        let host = NSHostingController(
            rootView: VStack(alignment: .leading, spacing: 2) {
                ErrorCauseNote(error: Self.authShapedError)
            }
            .font(.caption))
        let rendered = host.sizeThatFits(in: NSSize(width: 300, height: 0))
        // Guidance (~3 lines) + error (~3–4 lines) at caption size: well
        // over one line's height, nowhere near the pathological figure.
        #expect(rendered.height > 50)
        #expect(rendered.height < 400)
    }
}
