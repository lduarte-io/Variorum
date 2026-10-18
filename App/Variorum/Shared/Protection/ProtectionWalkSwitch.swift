//
//  ProtectionWalkSwitch.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1b — WALK MACHINERY, DEBUG ONLY (PROVISIONAL P-VX306-U1b-9; the `VARIORUM_SCALE_FIXTURE` /
//  `VARIORUM_SEED_GATE_UNOWNED` idiom: zero Release bytes, zero store state). The new road's custody items live
//  in the DATA PROTECTION keychain, which no command-line tool reaches ("There is no command-line tool access to
//  the data protection keychain" — DTS; `/usr/bin/security` reads file-based keychains only — the U1b record's
//  lookup), and its Apple keys are iCloud Keychain items, out of any CLI's reach. So the walk's rule-8 rows (the
//  lifecycle's stage 5: "the silent item deleted by hand → the Apple wrap opens silently and the item is re-made";
//  "both gone → the typed field at once") are walked through THIS switch: a launch with
//  `VARIORUM_WALK_FORGET=silent` (or `apple`, or `silent,apple`) forgets those quiet roads ONCE, before the route
//  reads its facts — as a keychain reset would — through the production leaves, then the road runs as ever.
//
//  VX-306 U2 adds `memory` — every item of what this Mac REMEMBERS (the memory items, their sealed key-file mirror
//  with them) — so the walk's rule-27 rows ("everything gone", and a quiet-road open with no key file anywhere) and
//  rule 21's "this Mac remembers nothing" can be walked: no CLI reaches those data-protection items either.
//
//  Fenced four ways: compiled only in DEBUG; reached only on the new road (the one switch — a Debug build on the
//  Mac, the dev store's variant only); never in a hosted test run (the road's `writes`); once per process. It
//  forgets only the DEV scope's own items: every SILENT custody item of the scope (`silent`), the Apple keys
//  stamped with the library the live key file names (`apple` — an iCloud delete reaches every device on the Apple
//  account, dev-scope names only), and every memory item of the scope (`memory`). Never a product road; the walk's
//  record names each use.
//

import Foundation
import VariorumCore

#if DEBUG
nonisolated enum ProtectionWalkSwitch {
    static let environmentKey = "VARIORUM_WALK_FORGET"

    enum Road: String, CaseIterable, Sendable {
        case silent
        case apple
        /// VX-306 U2: what this Mac remembers — every memory item of the scope.
        case memory
    }

    /// `silent`, `apple`, `memory`, comma-separated (order and spaces free); anything else names nothing.
    static func parse(_ value: String?) -> Set<Road> {
        Set((value ?? "").split(separator: ",").compactMap {
            Road(rawValue: $0.trimmingCharacters(in: .whitespaces).lowercased())
        })
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var spent = false

    /// The launch's one forgetting (the process environment's), before the route's facts. A second call does
    /// nothing.
    static func forgetOnceIfAsked(_ ctx: RoadContext, environment: [String: String] = ProcessInfo.processInfo.environment) {
        let roads = parse(environment[environmentKey])
        guard !roads.isEmpty, ctx.writes else { return }
        lock.lock()
        let first = !spent
        spent = true
        lock.unlock()
        guard first else { return }
        forget(roads, ctx.system)
    }

    /// Forget `roads` through the production leaves — the dev scope's silent items; this library's Apple keys.
    static func forget(_ roads: Set<Road>, _ system: ProtectionSystem) {
        if roads.contains(.silent) {
            let silent = ((try? system.leaves.custody.custodyItems()) ?? []).filter { $0.itemClass == .silent }
            for item in silent {
                try? system.leaves.custody.deleteCustody(fingerprint: item.fingerprint, itemClass: .silent)
            }
            ProtectionOpenRoad.log("WALK SWITCH (\(environmentKey)): forgot \(silent.count) silent custody item(s) of scope \(system.scope)")
        }
        if roads.contains(.apple) {
            let libraryID = ((try? system.leaves.keyFiles.readLiveKeyFile()) ?? nil)?.libraryID
            let ids = libraryID.flatMap { try? system.leaves.apple.appleKeyIDs(ofLibrary: $0) } ?? []
            for id in ids { try? system.leaves.apple.deleteAppleKey(id: id) }
            ProtectionOpenRoad.log("WALK SWITCH (\(environmentKey)): forgot \(ids.count) Apple key(s) of library \(String((libraryID ?? "none").prefix(8)))")
        }
        if roads.contains(.memory) {
            let remembered = (try? system.leaves.memory.rememberedLibraryIDs()) ?? []
            for libraryID in remembered { try? system.leaves.memory.deleteMemory(libraryID: libraryID) }
            ProtectionOpenRoad.log("WALK SWITCH (\(environmentKey)): forgot \(remembered.count) memory item(s) of scope \(system.scope)")
        }
    }
}
#endif
