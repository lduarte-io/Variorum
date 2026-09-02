//
//  ReadArrivalMeasureTests.swift
//  VariorumTests
//
//  The Act 10 correction round, ladder round 1 — R1-9: row 83 primed the
//  Blocks mode's rows before its observation so the mode arrives painted;
//  its brief asked which OTHER modes arrive blank and G's record named only
//  Blocks. Read's host started three observations with no prime and its
//  `edit` face rendered from `model.rows` — the same first-delivery blank.
//  Now Read PRIMES its rows the same way (`primeRows` before `start`; the
//  tray and pools observations wait). This is the Blocks measure pin's
//  shape over the Read host: mount → the first painted `edit` row, printed
//  and held under a SANITY ceiling (the in-memory harness cannot reproduce
//  the encrypted store's delay — the dev-store series in the record is the
//  number her hands feel).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Read arrives painted (ladder R1-9)", .serialized)
struct ReadArrivalMeasureTests {
    static let ceiling: TimeInterval = 1.5

    private nonisolated static func pumpRunLoop(_ seconds: TimeInterval) {
        MainActor.assumeIsolated {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }
    }

    @Test func theFirstEditRowPaintsWithinTheCeilingOnATwoHundredBlockNote() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 9))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "the boscombe valley mystery")
            for i in 1...215 {
                _ = try session.operations.newBlock(
                    in: post.id, text: "Block \(i): a sentence of the story, long enough to read as prose.")
            }
            ReadModeView.remember(.edit, postID: post.id)
            #if DEBUG
            ReadModeOracle.reset()
            #endif
            _ = session.commandRouter.registerDetail(postID: post.id, mode: .read) { _ in }
            let model = BlockTOCViewModel(session: session, postID: post.id)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1100, height: 750),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
                UserDefaults.standard.removeObject(forKey: ReadModeView.faceKey(post.id))
                session.commandRouter.forgetCurrentBlock(for: post.id)
            }
            let hosting = NSHostingView(rootView: AnyView(
                ReadModeView(session: session, postID: post.id, model: model)
                    .environment(ThemeStore(session: session))))
            hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 750)
            window.contentView = hosting
            let mountedAt = Date()
            window.makeKeyAndOrderFront(nil)
            #if DEBUG
            let deadline = Date().addingTimeInterval(6)
            while Date() < deadline, ReadModeOracle.firstEditRowPaintedAt == nil {
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                Self.pumpRunLoop(0.005)
                await Task.yield()
            }
            let painted = try #require(ReadModeOracle.firstEditRowPaintedAt, "the edit face painted a row")
            let elapsed = painted.timeIntervalSince(mountedAt)
            print("[ladder R1-9] Read: mount → first painted edit row in \(elapsed) s (ceiling \(Self.ceiling) s)")
            #expect(elapsed <= Self.ceiling,
                    "the first row paints within \(Self.ceiling) s of the mount: \(elapsed)")
            #endif
        }
    }
}
