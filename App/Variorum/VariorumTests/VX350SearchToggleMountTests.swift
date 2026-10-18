//
//  VX350SearchToggleMountTests.swift
//  VariorumTests (Mac)
//
//  **VX-350 (the VX-348 run, U3) — the 🔍 door, mounted.** Her words: the
//  squeezed search field "should at least turn into a search icon like
//  magnifying glass and clicking on it should still do something, even if
//  just opening it in the pane below." At a narrow room the row's collapsed
//  class shows the 🔍 in the field's place; a press opens the field on its own
//  line BELOW the controls (the caret in it — the view's half, walked); what
//  she types, a search, or a question cleared never adds or removes that line
//  (her state, not the text — P-U3-5's invariant kept); a press on the empty
//  open field closes it; a press while it holds a question puts the caret
//  back (a question is never hidden by a press).
//
//  New API (the 🔍's oracle slot, the model's press) — not in the red product;
//  the red-on-old pins are `VX350NarrowLibraryTests`.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-350 — the 🔍 door opens the field below the controls", .serialized)
struct VX350SearchToggleMountTests {
    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    private static func settle(_ window: NSWindow, _ hosting: NSView, _ seconds: TimeInterval = 0.5) async {
        let deadline = Date().addingTimeInterval(seconds)
        while Date() < deadline {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pumpRunLoop(0.03)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    private static func prompt(_ tokens: VoiceTokens) -> CGFloat {
        let field = TextField(tokens.chromeLabel(LibraryCatalogView.searchPrompt), text: .constant(""))
            .textFieldStyle(.roundedBorder)
            .font(tokens.small)
            .frame(maxWidth: LibraryCatalogView.searchFieldMaxWidth)
        return NSHostingController(rootView: field.fixedSize())
            .sizeThatFits(in: CGSize(width: 10_000, height: 10_000)).width
    }

    @Test(arguments: [ThemeVoice.terminal, .study])
    func theSearchDoorOpensTheFieldBelowAndTypingNeverMovesTheLines(voice: ThemeVoice) async throws {
        #if DEBUG
        let db = try AppDatabase.inMemory()
        let suite = "vx350-toggle-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 350))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            for index in 0..<6 {
                let note = try session.operations.createPost(title: "A note to pick from the listing \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words of \(index)")
            }
            try session.operations.setThemeVoice(voice)
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            await model.search()
            LibraryPanelOracle.reset()

            // A 400-pt room for the row: collapsed in both voices.
            let width: CGFloat = 400 + 48
            let window = NSWindow(
                contentRect: NSRect(x: 40, y: 40, width: width, height: 700),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let hosting = NSHostingView(rootView: AnyView(
                LibraryCatalogView(
                    session: session, model: model, library: LibraryViewModel(session: session),
                    tags: TagsViewModel(session: session), onOpen: { _ in })
                .environment(theme)))
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: 700)
            window.contentView = hosting
            window.orderFrontRegardless()
            defer {
                window.orderOut(nil)
                window.contentView = nil
                window.close()
            }
            await Self.settle(window, hosting, 1.2)
            let prompt = Self.prompt(theme.tokens(for: .light))

            @MainActor func read() throws -> (root: CGRect, controls: CGRect, field: CGRect, toggle: CGRect) {
                (try #require(LibraryPanelOracle.rootFrame), try #require(LibraryPanelOracle.controlsFrame),
                 try #require(LibraryPanelOracle.searchFieldFrame), try #require(LibraryPanelOracle.searchToggleFrame))
            }

            // A first open of the field may have come from the window's own
            // first responder (the field taking the keyboard opens it): close
            // it the way she would, so the walk starts from the closed door.
            if model.searchFieldOpened, model.query.isEmpty {
                #expect(model.pressSearchToggle() == .close)
                await Self.settle(window, hosting)
            }
            let closed = try read()
            print("[VX-350 toggle] \(voice) · closed · controls \(closed.controls) · field \(closed.field) · toggle \(closed.toggle)")
            #expect(closed.toggle.minX >= closed.controls.minX - 0.5 && closed.toggle.maxX <= closed.controls.maxX + 0.5,
                    "\(voice): the 🔍 sits in the row (\(closed.toggle) in \(closed.controls))")
            #expect(closed.field.maxX < closed.root.minX, "\(voice): the closed field is not shown (\(closed.field))")

            // The press: the field opens on its own line below the controls.
            #expect(model.pressSearchToggle() == .openAndFocus)
            await Self.settle(window, hosting)
            let open = try read()
            print("[VX-350 toggle] \(voice) · open · controls \(open.controls) · field \(open.field)")
            #expect(open.field.minX >= open.root.minX, "\(voice): the open field is shown (\(open.field))")
            #expect(open.field.minY >= closed.controls.maxY - 0.5,
                    "\(voice): the field opens BELOW the controls (\(open.field.minY) vs \(closed.controls.maxY))")
            #expect(open.field.width >= prompt - 0.5, "\(voice): the open field shows its whole prompt (\(open.field.width) of \(prompt))")
            #expect(open.controls.height > closed.controls.height + 15, "\(voice): one line more (\(closed.controls.height) → \(open.controls.height))")
            #expect(open.controls.maxX <= open.root.maxX + 0.5, "\(voice): the row fits")

            // Typing, a question cleared: the line count holds (her state, not the text).
            for question in ["pick", "pick from the listing", ""] {
                model.query = question
                await model.search()
                await Self.settle(window, hosting)
                let typed = try read()
                #expect(abs(typed.controls.height - open.controls.height) < 0.5,
                        "\(voice): \"\(question)\" moved the line count (\(open.controls.height) → \(typed.controls.height))")
                #expect(typed.field.minX >= typed.root.minX, "\(voice): \"\(question)\" hid the field")
            }

            // A press while it holds a question: the caret back, nothing hidden.
            model.query = "pick"
            await model.search()
            #expect(model.pressSearchToggle() == .focus, "\(voice): a question is never hidden by a press")
            await Self.settle(window, hosting)
            #expect(try read().field.minX >= closed.root.minX)

            // Empty and open: the press closes it — the row back to its lines.
            model.query = ""
            await model.search()
            #expect(model.pressSearchToggle() == .close)
            await Self.settle(window, hosting)
            let reclosed = try read()
            #expect(reclosed.field.maxX < reclosed.root.minX, "\(voice): closed again, not shown")
            #expect(abs(reclosed.controls.height - closed.controls.height) < 0.5,
                    "\(voice): back to its lines (\(closed.controls.height) vs \(reclosed.controls.height))")
        }
        #endif
    }
}
