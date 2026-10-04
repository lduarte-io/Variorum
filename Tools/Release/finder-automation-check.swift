// finder-automation-check.swift — Phase 13r U3-A, R-13r-10. make-dmg.sh lays out the DMG's window by
// AppleScript against Finder (her ruled road: "the .DS_Store written by AppleScript against the mounted
// read-write image"), and macOS lets a process script Finder only with the user's consent (System
// Settings ▸ Privacy & Security ▸ Automation ▸ <the terminal app> ▸ Finder). This asks the system whether
// THIS process's host may, WITHOUT prompting unless --ask is given — so the release pipeline refuses at
// PREFLIGHT, before an hour of archive and notarization, instead of hanging mid-run on a consent prompt.
//
//   swiftc -O -o finder-automation-check Tools/Release/finder-automation-check.swift
//   finder-automation-check [--ask]
//
// Exit 0 = allowed · 3 = not yet asked (run once with --ask, with her at the machine) · 4 = denied (her
// System Settings toggle) · 5 = anything else (the raw status is printed).

import CoreServices
import Foundation

let ask = CommandLine.arguments.contains("--ask")
var target = AEAddressDesc()
let finder = Array("com.apple.finder".utf8)
let created = finder.withUnsafeBytes {
    AECreateDesc(DescType(typeApplicationBundleID), $0.baseAddress, finder.count, &target)
}
guard created == noErr else { print("finder-automation-check: AECreateDesc failed (\(created))"); exit(5) }
defer { AEDisposeDesc(&target) }
let status = AEDeterminePermissionToAutomateTarget(
    &target, AEEventClass(typeWildCard), AEEventID(typeWildCard), ask)
switch Int(status) {
case Int(noErr):
    print("finder-automation-check: ALLOWED — this host may lay out the DMG window in Finder")
    exit(0)
case -1744:  // errAEEventWouldRequireUserConsent
    print("finder-automation-check: NOT YET ASKED — run `Tools/Release/make-dmg.sh --check --ask` once with her at the machine, and she answers OK")
    exit(3)
case -1743:  // errAEEventNotPermitted
    print("finder-automation-check: DENIED — HER HANDS: System Settings ▸ Privacy & Security ▸ Automation ▸ (the terminal app running the pipeline) ▸ turn ON “Finder”")
    exit(4)
default:
    print("finder-automation-check: status \(status) (Finder not running, or an unexpected answer)")
    exit(5)
}
