//
//  MobileFlightFenceProbeTests.swift
//  VariorumMobileTests
//
//  **DIAGNOSTIC, NOT A PIN** (VM-2 iteration r1 — the record's §5 "Iteration
//  r1"). It asserts nothing; it prints `VM2-PROBE` lines (positions, lengths,
//  counts and flags only — the E1 trace's own numbers, never text) and is
//  removed, or turned into a pin, once its question is settled.
//
//  THE QUESTION. The first stage window trapped the host on four UIKit
//  `insertText` calls, every one at the START of a non-empty block with a
//  separator after it — one with no fence code at all (a plain key after a
//  divide, on the pre-fix tree). The trap is `storageDidEdit`'s `.refuse` arm:
//  the report did not bind to the gate's arming, and the fallback's widened span
//  crossed the separator. Reading cannot say WHY the arming did not bind. These
//  cases separate the candidates in one short cycle:
//    · position alone (a block start, no structural act before it);
//    · the state a divide leaves (the door's render + caret write);
//    · the posture (a text view in no window vs the key window's first
//      responder — VX-282 C-1's measured posture, VM-19's class);
//    · a stale selection (the caret re-placed away and back before the key).
//  Each case runs with its OWN armed trace recorder and a COUNTING assertion
//  handler (task-scoped, so nothing running beside it is touched), so a desync
//  is reported as a number instead of stopping the host.
//

import Dependencies
import Foundation
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func probeHost(_ surface: MobileWriteSurfaceView) throws -> UIWindow {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let scene = try #require(
        scenes.first { $0.activationState == .foregroundActive } ?? scenes.first,
        "the test host has a window scene to type in")
    let window = UIWindow(windowScene: scene)
    window.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    let controller = UIViewController()
    controller.view.addSubview(surface)
    window.rootViewController = controller
    UIApplication.shared.sendAction(
        #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    window.makeKeyAndVisible()
    _ = surface.textView.becomeFirstResponder()
    return window
}

@MainActor
private func probeDismiss(_ window: UIWindow, _ surface: MobileWriteSurfaceView) {
    _ = surface.textView.resignFirstResponder()
    window.isHidden = true
    window.rootViewController = nil
}

@MainActor
@Suite("VM-2 r1 — DIAGNOSTIC: does a UIKit insert at a block's start bind? (VM2-PROBE lines)",
       .serialized)
struct MobileFlightFenceProbeTests {
    private enum Posture: String { case unmounted, keyed }

    private static let threeBlocks = ["Alpha beta.", "Gamma delta.", "Second block prose."]
    private static let twoBlocks = ["Alpha beta. Gamma delta.", "Second block prose."]

    /// One case: optionally divide (the door, awaited — no flight hold), then
    /// optionally re-place the caret, then ONE `insertText("Z")`; print what the
    /// gate and the storage report did.
    private func probe(
        _ name: String, posture: Posture, blocks: [String],
        divideAt: Int? = nil, caret: [Int] = []
    ) async throws {
        try await MobileEditTrace.$testRecorder.withValue(
            MobileEditTrace.Recorder(armed: true)
        ) {
            let fired = LockIsolated(0)
            try await EditorAssertionSeam.$handler.withValue({ _, _, _ in
                fired.withValue { $0 += 1 }
            }) {
                try await withEditorWorld { session, _ in
                    let postID = try await makePost(session, blocks: blocks)
                    let (model, surface) = await makeSurfaceEditor(session, postID: postID)
                    let window = posture == .keyed ? try probeHost(surface) : nil
                    defer { if let window { probeDismiss(window, surface) } }
                    let view = surface.textView
                    if let divideAt {
                        await model.structural.divide(atSurfaceCaret: divideAt)
                    }
                    for location in caret {
                        view.selectedRange = NSRange(location: location, length: 0)
                    }
                    MobileEditTrace.clear()
                    let selection = view.selectedRange
                    let lengthBefore = view.textStorage.length
                    let entriesBefore = model.index.entries.map(\.length)
                    view.insertText("Z")
                    for _ in 0..<50 { await Task.yield() }
                    let s = MobileEditTrace.summary
                    print("VM2-PROBE \(name) posture=\(posture.rawValue) divided=\(divideAt != nil)"
                        + " firstResponder=\(view.isFirstResponder) selection=\(selection.location)"
                        + "+\(selection.length) entries=\(entriesBefore) grew=\(view.textStorage.length - lengthBefore)"
                        + " desyncs=\(model.desyncRecoveryCount) asserts=\(fired.value)"
                        + " consults=\(s.consults) reports=\(s.reports) gateless=\(s.gatelessReports)"
                        + " rejected=\(s.armingsRejected) mismatches=\(s.mismatches)")
                    for event in MobileEditTrace.events {
                        print("VM2-PROBE \(name)   \(MobileEditTrace.line(for: event))")
                    }
                }
            }
        }
    }

    // Position alone — no structural act before the key.
    @Test func p1BlockStartUnmounted() async throws {
        try await probe("p1", posture: .unmounted, blocks: Self.threeBlocks, caret: [12])
    }
    @Test func p2BlockStartKeyed() async throws {
        try await probe("p2", posture: .keyed, blocks: Self.threeBlocks, caret: [12])
    }
    // The control: mid-block (routed in the first window on both trees).
    @Test func p3MidBlockUnmounted() async throws {
        try await probe("p3", posture: .unmounted, blocks: Self.threeBlocks, caret: [5])
    }
    // After a divide, at the caret the door lands (the trap's exact shape).
    @Test func p4AfterDivideUnmounted() async throws {
        try await probe("p4", posture: .unmounted, blocks: Self.twoBlocks, divideAt: 12)
    }
    @Test func p5AfterDivideKeyed() async throws {
        try await probe("p5", posture: .keyed, blocks: Self.twoBlocks, divideAt: 12)
    }
    // After a divide, the caret moved away and back first (a stale selection?).
    @Test func p6AfterDivideReselectedUnmounted() async throws {
        try await probe("p6", posture: .unmounted, blocks: Self.twoBlocks, divideAt: 12, caret: [0, 12])
    }
    @Test func p7AfterDivideReselectedKeyed() async throws {
        try await probe("p7", posture: .keyed, blocks: Self.twoBlocks, divideAt: 12, caret: [0, 12])
    }
}
