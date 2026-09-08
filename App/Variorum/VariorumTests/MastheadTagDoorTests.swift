//
//  MastheadTagDoorTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch A — row 15: **ONE tag door in the
//  masthead, and the field takes the cursor when it opens.** Her words:
//  *"showing a tag icon and a + tag at the same time … that's just sloppy"*;
//  her shape: *"clicking on the tag button … could slide out a neat 'tag
//  creator' field where your cursor is already active."*
//
//  Red-on-old: the pre-round cluster rendered TWO add-side doors — "＋ tag"
//  (a popover) and the ＃ (13k K12's fold) — and its `surfaceCapabilities`
//  declared two acts; the field lived in a popover that only a click could
//  open. (An accessibility-tree count of the drawn buttons was tried first
//  and is recorded as not available in this harness: an `NSHostingView`
//  exposes no accessibility children to a direct walk. The one-door claim
//  is therefore held by construction — the cards render without their ＋
//  (`chipsShowAddDoor`), the cluster declares one act, and the field
//  exists only after the door is used.)
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The masthead's one tag door (correction round, row 15)", .serialized)
struct MastheadTagDoorTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(_ window: NSWindow, _ hosting: NSView, turns: Int = 20) async {
        for _ in 0..<turns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private struct Host: View {
        let session: AppSession
        let postID: String
        @State var open: Bool
        var body: some View {
            MastheadTagCluster(
                session: session, postID: postID, tokens: .terminalLight, fieldOpen: $open)
                .padding(20)
                .frame(width: 520, height: 120, alignment: .topTrailing)
        }
    }

    /// The declaration half: ONE act, rendered by this cluster; the act
    /// carries the chord the fold used to hold.
    @Test func theClusterDeclaresExactlyTheOneTaggingAct() {
        #expect(MastheadTagCluster.surfaceCapabilities == [.tagNote])
        #expect(!MastheadTagCluster.chipsShowAddDoor,
                "the cards carry no ＋ in the masthead — the ＃ is the one door (the pre-round cluster rendered ＋ tag AND ＃)")
        #expect(CapabilityRegistry.capability(.tagNote).shortcutLabel == "\u{2318}\u{21e7}I")
        #expect(CapabilityRegistry.capability(.tagNote).doors.contains(.surface))
    }

    /// The drawn half: at rest there is no field; opened, the field is on
    /// screen and holds the keyboard focus — "your cursor is already active".
    @Test func oneDoorAtRestAndTheFieldTakesFocusWhenItOpens() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "tag me")

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 520, height: 120),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let closed = NSHostingView(rootView: Host(session: session, postID: post.id, open: false))
            closed.frame = NSRect(x: 0, y: 0, width: 520, height: 120)
            window.contentView = closed
            window.makeKeyAndOrderFront(nil)
            await settle(window, closed)
            #expect(!textFieldExists(in: closed), "no field until the door is used")

            // Open: the field is out and it is first responder.
            let opened = NSHostingView(rootView: Host(session: session, postID: post.id, open: true))
            opened.frame = NSRect(x: 0, y: 0, width: 520, height: 120)
            window.contentView = opened
            await settle(window, opened, turns: 30)
            #expect(textFieldExists(in: opened), "the inline field slid out")
            let responder = window.firstResponder
            #expect(responder is NSTextView || responder is NSTextField,
                    "the cursor is already active in the field (first responder is the field's editor), got \(String(describing: responder))")
        }
    }

    /// **Row 40 (her U-15): the field collapses when she clicks out of it —
    /// once the note already carries a tag.** Her words: *"if there's a tag
    /// already applied this new tag template shouldn't just sit here by
    /// default, it should collapse after you click out of it."* The field
    /// had no focus-loss road at all: only ⎋ and the ＃ closed it, so an
    /// empty template sat in the masthead beside her tags until she went
    /// back for it. The ＃ reopens it, unchanged.
    ///
    /// The untagged case is the deliberate other half: a note with NO tags
    /// keeps the field open, because there is nothing yet for the template
    /// to be sitting redundantly beside (her words are about the
    /// already-tagged case, and this is the reading recorded in §5.3).
    ///
    /// RED ON OLD: `open` stays true in both halves.
    @Test func theFieldCollapsesOnFocusLossOnceTheNoteCarriesATag() async throws {
        for tagged in [true, false] {
            let db = try AppDatabase.inMemory()
            try await withDependencies {
                $0.database = db
                $0.uuid = .incrementing
                $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            } operation: { @MainActor in
                let session = AppSession(database: db)
                let post = try session.operations.createPost(title: "tag me")
                if tagged {
                    let tag = try session.operations.createTag(name: "walked")
                    _ = try session.operations.applyTag(tag.id, toPost: post.id)
                }
                let box = FieldBox()

                let window = NSWindow(
                    contentRect: NSRect(x: 80, y: 80, width: 520, height: 160),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                defer {
                    window.orderOut(nil)
                    window.close()
                }
                let hosting = NSHostingView(
                    rootView: FocusHost(session: session, postID: post.id, box: box))
                hosting.frame = NSRect(x: 0, y: 0, width: 520, height: 160)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                await settle(window, hosting, turns: 40)
                #expect(textFieldExists(in: hosting), "the field is out to begin with")
                #expect(box.open, "…and the cluster still says so")

                // Click out: the field resigns, and the cluster decides.
                window.makeFirstResponder(nil)
                await settle(window, hosting, turns: 40)
                #expect(box.open == !tagged,
                        tagged
                            ? "a tagged note collapses the empty template"
                            : "an untagged note keeps its field on the first click")
            }
        }
    }

    private func textFieldExists(in view: NSView) -> Bool {
        if view is NSTextField { return true }
        return view.subviews.contains { textFieldExists(in: $0) }
    }
}

@MainActor
@Observable
private final class FieldBox {
    var open = true
}

@MainActor
private struct FocusHost: View {
    let session: AppSession
    let postID: String
    @Bindable var box: FieldBox
    var body: some View {
        MastheadTagCluster(
            session: session, postID: postID, tokens: .terminalLight, fieldOpen: $box.open)
            .padding(20)
            .frame(width: 520, height: 160, alignment: .topTrailing)
    }
}
