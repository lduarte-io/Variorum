//
//  VX668Trace.swift
//  Variorum (Mac)
//
//  **VX668-TRACE — TEMPORARY, DEBUG-only, REMOVED BEFORE MERGE** (VX-562's
//  precedent; the coordinator's declared trace, `notes/plans/fixes/vx-677-
//  editor-panes-ai-door.md` — "VX-668's trace declared" and the BATCH 5
//  RECORD). LOG LINES ONLY: every call site writes one `NSLog` line and
//  changes nothing (no state any product code reads — the trace's own clock
//  below is read by the trace alone). Release compiles this file to nothing,
//  and every call site is `#if DEBUG`-gated.
//
//  What it answers (the VX-440 record's "W-2, second pass", step 6): on the
//  read-in-full SHEET road the restore's landing parcel never reaches Write's
//  consumer, while the ROW road's does. The lines, both roads:
//    (a) the parcel's POST (`BlockHistoryModel.restore`), its road, and the
//        sheet's foot press / dismissal around it;
//    (b) `EditorView`'s `onChange` — its fire and the values it read — plus
//        each body evaluation's READ of the parcel (did the body re-run at
//        all?), and the consumer's decision;
//    (c) the settle hop's time (`overlayLayoutDidSettle`) and what it found,
//        the delivery's projection decision around the rewrite, and the
//        landing's outcome;
//  plus every OTHER road that can take or clear the parcel (the Takes/Lenses
//  consumer, the router's two clears) and the editor's / detail's lifecycle
//  (a remount would read as a new model id), so the one window names the
//  failed link instead of narrowing it again.
//
//  Read it with (her shell's `log` is a function — use the absolute path):
//    /usr/bin/log show --last 10m --style compact \
//      --predicate 'eventMessage CONTAINS "VX668-TRACE"'
//  In a hosted test run the same lines land in the xcodebuild log (NSLog).
//
//  Grep `VX668-TRACE` to remove every site (this file + the marked call
//  sites).
//

#if DEBUG
import AppKit
import Foundation

@MainActor
enum VX668Trace {
    /// The trace's own clock: the last MARK (a restore begun, a parcel
    /// posted, a sheet's foot pressed or its dismissal). The noisy points (a
    /// body evaluation, a settle hop, a projection) log only within
    /// `window` seconds of it, so an ordinary DEBUG run is not flooded.
    private static var lastMark: TimeInterval = -.greatestFiniteMagnitude
    static let window: TimeInterval = 4

    static var now: TimeInterval { ProcessInfo.processInfo.systemUptime }

    static func mark() { lastMark = now }

    static var isOpen: Bool { now - lastMark < window }

    /// One line, always.
    static func line(_ message: String) {
        NSLog("VX668-TRACE t=%.3f %@", now, message)
    }

    /// One line while the window is open.
    static func windowed(_ message: @autoclosure () -> String) {
        guard isOpen else { return }
        line(message())
    }

    /// A short id (the first 8 characters), or "nil".
    static func id(_ s: String?) -> String { s.map { String($0.prefix(8)) } ?? "nil" }

    /// A parcel's short id, or "nil".
    static func parcel(_ landing: RestoreLanding?) -> String {
        landing.map { String($0.id.uuidString.prefix(8)) } ?? "nil"
    }

    /// An object's address — a remount shows as a new address.
    static func object(_ o: AnyObject?) -> String {
        guard let o else { return "nil" }
        return String(describing: Unmanaged.passUnretained(o).toOpaque())
    }

    /// Where a text view's caret is, or "-".
    static func caret(_ textView: NSTextView?) -> String {
        textView.map { "\($0.selectedRange().location)" } ?? "-"
    }

    /// The window state around a line (key / main / an attached sheet).
    static func windowState(_ view: NSView?) -> String {
        guard let w = view?.window else { return "win=nil" }
        return "key=\(w.isKeyWindow) main=\(w.isMainWindow) sheet=\(w.attachedSheet != nil) "
            + "appKey=\(NSApp.keyWindow.map { $0 === w ? "this" : "other" } ?? "none")"
    }
}
#endif
