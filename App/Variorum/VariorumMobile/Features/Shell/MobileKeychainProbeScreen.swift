//
//  MobileKeychainProbeScreen.swift
//  VariorumMobile — DEBUG ONLY; compiled out of Release
//
//  pre-13x batch 0 — the PHONE half of the cross-device leg (Q3, design
//  §17b): a Settings-row sheet over the shared `SharedKeychainGroupProbe`
//  brain. Read what the Mac wrote under the SHARED access group, write from
//  this iPhone for the Mac to read, delete, or run the local round trip —
//  every result on screen as a selectable line (and on the console as a
//  `PRE13X-PROBE|` line). A dev instrument on the TK2 Spike door's terms:
//  outside the registry, `#if DEBUG`, deleted when batch 2's real Apple-key
//  item lands.
//

#if DEBUG

import SwiftUI
import UIKit

struct MobileKeychainProbeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var lines: [String] = []

    private var device: String { UIDevice.current.name }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(.footnote, design: .monospaced))
                            .textSelection(.enabled)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle("Keychain probe (pre-13x)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    Button("Read the other device's item") { readCross() }
                    Button("Write from this iPhone") { writeCross() }
                    Button("Delete the item") { deleteCross() }
                    Button("Local round trip") { local() }
                }
                .buttonStyle(.bordered)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.bar)
            }
            .onAppear {
                stamp("shared group: \(SharedKeychainGroupProbe.sharedGroup)")
                readCross()
            }
        }
    }

    private static let clock: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private func stamp(_ text: String) {
        let line = "\(Self.clock.string(from: Date()))  \(text)"
        lines.append(line)
        print("PRE13X-PROBE| \(line)")
    }

    private func readCross() {
        let (status, group) = SharedKeychainGroupProbe.defaultAccessGroup()
        stamp("this app's own (first) group: \(group ?? "nil") — \(SharedKeychainGroupProbe.describe(status))")
        stamp("read cross-device: \(SharedKeychainGroupProbe.readCrossDevice().summary)")
    }

    private func writeCross() {
        let status = SharedKeychainGroupProbe.writeCrossDevice(deviceName: device)
        stamp("write from \(device): \(SharedKeychainGroupProbe.describe(status))")
    }

    private func deleteCross() {
        stamp("delete: \(SharedKeychainGroupProbe.describe(SharedKeychainGroupProbe.deleteCrossDevice()))")
    }

    private func local() {
        let report = SharedKeychainGroupProbe.runLocalRoundTrip(deviceName: device)
        stamp(report.passed
              ? "local round trip: every must-hold step held"
              : "local round trip FAILED: \(report.failures)")
        for line in report.lines { stamp("   " + line) }
    }
}

#endif
