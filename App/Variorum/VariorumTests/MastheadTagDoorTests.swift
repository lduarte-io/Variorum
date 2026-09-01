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

    private func textFieldExists(in view: NSView) -> Bool {
        if view is NSTextField { return true }
        return view.subviews.contains { textFieldExists(in: $0) }
    }
}
