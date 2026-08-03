//
//  SpikeScreen.swift
//  VariorumMobile — Stage 0 TK2-on-iOS spike (THROWAWAY; deleted at stage close)
//
//  The DEBUG-gated door: a SwiftUI full-screen wrapper over the UIKit
//  bench. Auto-run: launching with TK2SPIKE_AUTORUN=1 in the environment
//  (or "-TK2SPIKE_AUTORUN" launch argument) opens the screen and runs the
//  whole scenario suite, printing TK2SPIKE| lines to stdout (capture via
//  `simctl launch --console-pty`) and to Documents/tk2spike-results.log.
//

#if DEBUG

import SwiftUI

enum SpikeLaunch {
    static var autoRunRequested: Bool {
        ProcessInfo.processInfo.environment["TK2SPIKE_AUTORUN"] != nil
            || ProcessInfo.processInfo.arguments.contains("-TK2SPIKE_AUTORUN")
    }
    static var uiTestBenchRequested: Bool {
        ProcessInfo.processInfo.environment["TK2SPIKE_UI"] != nil
            || ProcessInfo.processInfo.arguments.contains("-TK2SPIKE_UI")
    }
}

struct SpikeBenchRepresentable: UIViewControllerRepresentable {
    let onReady: (SpikeBenchViewController) -> Void

    func makeUIViewController(context: Context) -> SpikeBenchViewController {
        let vc = SpikeBenchViewController()
        DispatchQueue.main.async { onReady(vc) }
        return vc
    }

    func updateUIViewController(_ uiViewController: SpikeBenchViewController, context: Context) {}
}

struct SpikeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var bench: SpikeBenchViewController?
    @State private var running = false

    var body: some View {
        NavigationStack {
            SpikeBenchRepresentable { vc in
                bench = vc
                if SpikeLaunch.autoRunRequested && !running {
                    runAll(vc)
                }
            }
            .ignoresSafeArea(.keyboard)
            .navigationTitle("TK2 Spike")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if running {
                        ProgressView()
                    } else {
                        Menu("Run") {
                            Button("Run ALL") { bench.map(runAll) }
                            Button("1 Fallback inventory") {
                                run { await $0.runFallbackInventory() }
                            }
                            Button("2 Scale 50k") { run { await $0.runScale(words: 50_000) } }
                            Button("2 Jumps") { run { await $0.runJumps() } }
                            Button("2 Typing") { run { await $0.runTyping() } }
                            Button("3 Attribute survival") {
                                run { await $0.runAttributeSurvival() }
                            }
                            Button("4 Gesture geometry") { run { await $0.runGestureGeometry() } }
                            Button("6 Keyboard") { run { await $0.runKeyboard() } }
                        }
                    }
                }
            }
        }
    }

    private func run(_ body: @escaping (SpikeScenarios) async -> Void) {
        guard let bench, !running else { return }
        running = true
        Task {
            await body(SpikeScenarios(bench: bench))
            running = false
        }
    }

    private func runAll(_ vc: SpikeBenchViewController) {
        guard !running else { return }
        running = true
        Task {
            await SpikeScenarios(bench: vc).runAll()
            running = false
        }
    }
}

#endif
