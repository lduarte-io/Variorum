//
//  SharedKeychainGroupProbeDoor.swift
//  Variorum (Mac) — DEBUG ONLY; compiled out of Release
//
//  pre-13x batch 0 — the MAC half of the cross-device leg (Q3, design
//  §17b): a Help-menu door that shows the shared-group probe item's current
//  state and lets the author write it from this Mac, read what the phone
//  wrote, delete it, or run the local round trip — an NSAlert flow, because
//  a five-minute sitting wants one click and a sentence, not a window.
//
//  OUTSIDE the capability registry deliberately: this is a dev instrument,
//  never a user-facing act (the phone's TK2 Spike and perf-fixture doors are
//  the precedent) — it lives under `#if DEBUG`, so the registry walk's
//  "every rendered door is declared" holds for every build a user can hold.
//  Deleted when the design's real Apple-key item lands (batch 2).
//

#if DEBUG

import AppKit
import Foundation

@MainActor
enum SharedKeychainGroupProbeDoor {
    static func present() {
        let device = Host.current().localizedName ?? "this Mac"
        let current = SharedKeychainGroupProbe.readCrossDevice()
        let (defaultStatus, defaultGroup) = SharedKeychainGroupProbe.defaultAccessGroup()
        let alert = NSAlert()
        alert.messageText = "Keychain shared-group probe (pre-13x batch 0)"
        alert.informativeText = """
            The cross-device item — service \(SharedKeychainGroupProbe.probeService), \
            account \(SharedKeychainGroupProbe.crossDeviceAccount):
            \(current.summary)

            Shared group: \(SharedKeychainGroupProbe.sharedGroup)
            This app's own (first) group: \(defaultGroup ?? "nil") — \
            \(SharedKeychainGroupProbe.describe(defaultStatus))

            Write here, then read on the phone (and the reverse). iCloud Keychain \
            propagation takes seconds to minutes — read again rather than assuming.
            """
        alert.addButton(withTitle: "Read again")
        alert.addButton(withTitle: "Write from this Mac")
        alert.addButton(withTitle: "Delete the item")
        alert.addButton(withTitle: "Local round trip")
        alert.addButton(withTitle: "Close")
        let fourthButton = NSApplication.ModalResponse(rawValue: NSApplication.ModalResponse.alertThirdButtonReturn.rawValue + 1)
        switch alert.runModal() {
        case .alertFirstButtonReturn:
            present()
        case .alertSecondButtonReturn:
            let status = SharedKeychainGroupProbe.writeCrossDevice(deviceName: device)
            inform("Write from this Mac: \(SharedKeychainGroupProbe.describe(status))")
            present()
        case .alertThirdButtonReturn:
            let status = SharedKeychainGroupProbe.deleteCrossDevice()
            inform("Delete: \(SharedKeychainGroupProbe.describe(status))")
            present()
        case fourthButton:
            let report = SharedKeychainGroupProbe.runLocalRoundTrip(deviceName: device)
            for line in report.lines { NSLog("PRE13X-PROBE| %@", line) }
            let headline = report.passed
                ? "Local round trip: every must-hold step held."
                : "Local round trip FAILED: \(report.failures)"
            inform(headline + "\n\n" + report.lines.joined(separator: "\n"))
            present()
        default:
            break
        }
    }

    private static func inform(_ text: String) {
        let alert = NSAlert()
        alert.messageText = "Keychain shared-group probe"
        alert.informativeText = text
        alert.runModal()
    }
}

#endif
