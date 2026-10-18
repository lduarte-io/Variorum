//
//  AppDiagnosticsLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `DiagnosticsLeaf` (`Executor/Leaves.swift`): the app's existing diagnostics
//  seam — the unified log under `io.lduarte.Variorum` / `protection` (the category today's protection code
//  logs to) — and the typed entries kept in memory for a Diagnostics face to list. NEVER KEY MATERIAL
//  (design §3.2): the executor speaks in act names, step names and eight-character fingerprints, and the
//  typed `ProtectionDiagnostic` can carry nothing else.
//

import Foundation
import os
import VariorumCore

nonisolated final class AppDiagnosticsLeaf: DiagnosticsLeaf, @unchecked Sendable {
    private let logger = Logger(subsystem: "io.lduarte.Variorum", category: "protection")
    private let lock = NSLock()
    private var entries: [ProtectionDiagnostic] = []
    /// The most recent entries kept (a Diagnostics face lists them).
    static let kept = 200

    func log(_ line: String) {
        logger.info("\(line, privacy: .public)")
    }

    func report(_ entry: ProtectionDiagnostic) {
        lock.lock()
        entries.append(entry)
        if entries.count > Self.kept { entries.removeFirst(entries.count - Self.kept) }
        lock.unlock()
        logger.notice("diagnostic: \(String(describing: entry), privacy: .public)")
    }

    /// What Diagnostics lists, oldest first.
    var reported: [ProtectionDiagnostic] {
        lock.lock()
        defer { lock.unlock() }
        return entries
    }
}
