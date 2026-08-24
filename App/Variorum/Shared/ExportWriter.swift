//
//  ExportWriter.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 11b, Step B1 — writes a bulk-export manifest under a root folder:
//  creates the subfolders the relative paths name, one file each,
//  atomically. Pure file I/O over pure data; tested directly.
//
//  Phase 13l, Act 5 (ledger row 16) — HOISTED HERE FROM
//  `Features/Export/ExportModel.swift`, unchanged. The reason is the
//  MobileSoul §3 rule rather than tidiness: that file imports AppKit, so
//  everything in it is Mac-only by compilation, and this type is neither a
//  Mac thing nor a face — it is the ONE place that turns a
//  `Queries.ExportFile` manifest into files on disk. The automated
//  plain-text insurance (`MarkdownInsurance`) needs exactly that, and
//  copying twelve lines of it would have created the forked-brain class the
//  KnownIssues row is about. `ExportModel` calls it unchanged, so its pins
//  ride unmodified — the address moved, the behaviour did not.
//

import Foundation
import VariorumCore

enum ExportWriter {
    /// Nonisolated: the bulk gesture runs this DETACHED (11b round 1, NIT 3
    /// — file I/O never on the MainActor; the target defaults to MainActor
    /// isolation).
    @discardableResult
    nonisolated static func write(_ files: [Queries.ExportFile], to root: URL) throws -> Int {
        for file in files {
            let destination = root.appendingPathComponent(file.relativePath)
            try FileManager.default.createDirectory(
                at: destination.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            try Data(file.contents.utf8).write(to: destination, options: .atomic)
        }
        return files.count
    }
}
