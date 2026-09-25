//
//  C2WalkProbe.swift — 18k C2 TEMPORARY ("WIP: probe"; REMOVED before the
//  unit closes). An env-gated (C2_WALK=1) in-app driver: this session's
//  terminal host holds no Accessibility / Screen Recording grant, so the GUI
//  cannot be driven from outside. It navigates through the shell's own doors
//  and the book's DEBUG focus door, and logs the C2PROBE chain.
//

#if DEBUG
import AppKit
import GRDB
import SwiftUI
import VariorumCore

extension RootView {
    func c2Walk(router: ShellRouter) async {
        guard ProcessInfo.processInfo.environment["C2_WALK"] == "1" else { return }
        try? await Task.sleep(for: .seconds(6))
        struct Candidate { var reading: String; var post: String; var title: String; var blocks: Int }
        let candidates: [Candidate] = (try? await session.database.read { db in
            try Row.fetchAll(db, sql: """
                SELECT rp.reading_id AS r, c.id AS p, COALESCE(c.title, '') AS t,
                       COUNT(cb.id) AS n
                FROM reading_post rp
                JOIN reading rd ON rd.id = rp.reading_id AND rd.deleted_at IS NULL
                     AND rd.locked = 0 AND rd.kind = 'curated'
                JOIN container c ON c.id = rp.post_id AND c.deleted_at IS NULL
                JOIN container_block cb ON cb.container_id = c.id AND cb.deleted_at IS NULL
                WHERE rp.deleted_at IS NULL
                GROUP BY rp.reading_id, c.id
                ORDER BY n DESC
                """).map { Candidate(reading: $0["r"], post: $0["p"], title: $0["t"], blocks: $0["n"]) }
        }) ?? []
        guard let long = candidates.first else {
            NSLog("C2PROBE walk: no curated unlocked book with notes — abort")
            return
        }
        let short = candidates.last { $0.reading == long.reading && $0.blocks <= 3 }
        NSLog("C2PROBE walk: book=%@ long=%@ '%@' blocks=%d short=%@ blocks=%d",
              String(long.reading.prefix(8)), String(long.post.prefix(8)), long.title, long.blocks,
              String(short?.post.prefix(8) ?? "none"), short?.blocks ?? -1)
        router.adopt(.reading(long.reading))
        try? await Task.sleep(for: .seconds(4))
        guard let focus = BookOutlineGeometry.focusDoors[long.reading] else {
            NSLog("C2PROBE walk: the book published no focus door (not in Outline?) — abort")
            return
        }

        func block(_ label: String, seconds: Double) async {
            try? await Task.sleep(for: .seconds(seconds))
            NSLog("C2PROBE walk: [%@] makes=%d updates=%d writes=%d dismantles=%d active=%@ editing=%@",
                  label, C2Probe.makes, C2Probe.updates, C2Probe.writes, C2Probe.dismantles,
                  session.editorRouter.active.map { C2Probe.id($0) } ?? "nil",
                  session.editorRouter.editing.map { C2Probe.id($0) } ?? "nil")
        }

        // 0 — B-1's OWN gesture: expand read-cheap first, then click into the
        // prose (a focus WITH a caret — the read tier's onFocusRequest road).
        if ProcessInfo.processInfo.environment["C2_GESTURE"] == "expandThenClick" {
            for target in [long] + (short.map { [$0] } ?? []) {
                C2Probe.reset(); C2Probe.armed = true
                NSLog("C2PROBE walk: ===== EXPAND %@ (%d blocks)", String(target.post.prefix(8)), target.blocks)
                C2Probe.expandDoors[target.reading]?(target.post)
                await block("expanded read-cheap", seconds: 3)
                NSLog("C2PROBE walk: ===== CLICK-FOCUS %@", String(target.post.prefix(8)))
                C2Probe.caretFocusDoors[target.reading]?(target.post, 120)
                await block("click-focused", seconds: 3)
                C2Probe.armed = false
                focus(nil)
                try? await Task.sleep(for: .seconds(2))
            }
        }

        // 1 — the SHORT note first (the control: B-1 measured one mount).
        if let short {
            C2Probe.reset(); C2Probe.armed = true
            NSLog("C2PROBE walk: ===== FOCUS SHORT %@", String(short.post.prefix(8)))
            focus(short.post)
            await block("short focused", seconds: 3)
            C2Probe.armed = false
            focus(nil)
            try? await Task.sleep(for: .seconds(2))
        }

        // 2 — the LONG note (the row's fixture).
        C2Probe.reset(); C2Probe.armed = true
        NSLog("C2PROBE walk: ===== FOCUS LONG %@", String(long.post.prefix(8)))
        focus(long.post)
        await block("long focused", seconds: 3)

        // 3 — typing in the live editor (the one in a window), then undone.
        if let model = session.editorRouter.active, let textView = model.textView {
            NSLog("C2PROBE walk: ===== TYPE (inWindow=%d)", textView.window != nil ? 1 : 0)
            let location = min(40, (textView.string as NSString).length)
            textView.setSelectedRange(NSRange(location: location, length: 0))
            for _ in 0..<5 {
                textView.insertText("x", replacementRange: textView.selectedRange())
                try? await Task.sleep(for: .milliseconds(120))
            }
            for _ in 0..<5 {
                textView.deleteBackward(nil)
                try? await Task.sleep(for: .milliseconds(120))
            }
            await block("typed and deleted", seconds: 2)

            // 4 — scrolled away and back (the near band's round trip).
            if let scroll = outlineScroll(containing: textView) {
                let doc = scroll.documentView?.frame.height ?? 0
                let start = scroll.contentView.bounds.origin
                NSLog("C2PROBE walk: ===== SCROLL AWAY (doc=%.0f from=%.0f)", doc, start.y)
                scroll.contentView.scroll(to: NSPoint(x: start.x, y: max(0, doc - scroll.contentView.bounds.height)))
                scroll.reflectScrolledClipView(scroll.contentView)
                await block("scrolled away", seconds: 3)
                NSLog("C2PROBE walk: ===== SCROLL BACK")
                scroll.contentView.scroll(to: start)
                scroll.reflectScrolledClipView(scroll.contentView)
                await block("scrolled back", seconds: 3)
            } else {
                NSLog("C2PROBE walk: no outline scroll found")
            }
        } else {
            NSLog("C2PROBE walk: no active editor after focus")
        }
        await block("end", seconds: 1)
        C2Probe.armed = false
        focus(nil)
        try? await Task.sleep(for: .seconds(2))
        router.adopt(.shelf)
        try? await Task.sleep(for: .seconds(2))
        NSLog("C2PROBE walk: done — terminating the dev app")
        // Off this task: a synchronous terminate from inside a main-actor
        // task hung in terminateLater (walk 1).
        DispatchQueue.main.async { NSApp.terminate(nil) }
    }

    private func outlineScroll(containing view: NSView) -> NSScrollView? {
        var candidate = view.enclosingScrollView
        while let scroll = candidate {
            if (scroll.documentView?.frame.height ?? 0) > scroll.contentView.bounds.height + 1000 {
                return scroll
            }
            candidate = scroll.enclosingScrollView
        }
        return nil
    }
}
#endif
