// vis-tcc [bundle-id[@quit] …] — does THIS terminal (the responsible process) hold the grants the
// harness uses? Prints "AX <0|1> SCREEN <0|1>" and, per target, "AE:<id> <state>" for the Automation
// (Apple Events) grant: granted · denied · undetermined · notrunning · error(<n>). A plain id asks about
// ANY event (the System Events scripting every act sends); `<id>@quit` asks about the ONE event the
// harness sends the dev app — the core suite's quit ('aevt'/'quit').
// CHECKS ONLY, NEVER PROMPTS (`askUserIfNeeded: false`) — a consent dialog is the author's to answer,
// and the incident this harness met was exactly a prompt minted by a script (U-VIS round 1, MINOR-6).
import ApplicationServices
import CoreGraphics
import CoreServices
import Foundation

// LINE-buffered even into a pipe (round 2, MINOR-R2-3): the driver runs this under a time limit, and
// a check that blocks on a PENDING consent prompt is killed by SIGALRM, which flushes nothing — every
// line already known must be out before the next question is asked.
setvbuf(stdout, nil, _IOLBF, 0)
print("AX \(AXIsProcessTrusted() ? 1 : 0) SCREEN \(CGPreflightScreenCaptureAccess() ? 1 : 0)")
for spec in CommandLine.arguments.dropFirst() {
    let quitOnly = spec.hasSuffix("@quit")
    let id = quitOnly ? String(spec.dropLast(5)) : spec
    let target = NSAppleEventDescriptor(bundleIdentifier: id)
    let status = AEDeterminePermissionToAutomateTarget(
        target.aeDesc,
        quitOnly ? AEEventClass(kCoreEventClass) : typeWildCard,
        quitOnly ? AEEventID(kAEQuitApplication) : typeWildCard,
        false)
    let state: String
    switch status {
    case noErr: state = "granted"
    case OSStatus(errAEEventNotPermitted): state = "denied"
    case OSStatus(errAEEventWouldRequireUserConsent): state = "undetermined"
    case OSStatus(procNotFound): state = "notrunning"
    default: state = "error(\(status))"
    }
    print("AE:\(spec) \(state)")
}
