//
//  CrashReportStore.swift
//  Variorum (MAC ONLY)
//
//  Phase 13r U3-B — where a received crash report lives: ONE FILE PER
//  REPORT, holding the bytes exactly as MetricKit handed them (R-13r-5:
//  "every payload is shown to the user VERBATIM before anything leaves the
//  machine"). The same file is what the Diagnostics surface shows AND what
//  Send attaches, so what she reads is what would go — by construction, not
//  by a copy kept in step.
//
//  LOCAL and outside the library: `Application Support/Diagnostics/Crash
//  Reports/` in this app's own container — a sibling of the library folder,
//  never inside it, so no backup, export or sync ever carries a report. A
//  Debug build has its own container, so the dev app's reports and the real
//  app's never mix.
//

import Foundation

/// One received report. `bytes` are the file's bytes, verbatim.
nonisolated struct CrashReport: Identifiable, Equatable, Sendable {
    /// The file name — unique, and stable for the report's life.
    let id: String
    let url: URL
    let receivedAt: Date
    let bytes: Data

    /// The report as text, EXACTLY its bytes — or nil if they are not UTF-8,
    /// in which case the surface says it cannot show them and offers no Send
    /// (only what was shown verbatim may leave).
    var text: String? { String(data: bytes, encoding: .utf8) }

    /// A one-line heading read OUT of the report (never added to it): the
    /// app and OS versions MetricKit recorded, when present.
    var heading: String? {
        guard let object = try? JSONSerialization.jsonObject(with: bytes) as? [String: Any],
              let meta = object["diagnosticMetaData"] as? [String: Any]
        else { return nil }
        var parts: [String] = []
        if let app = meta["appVersion"] as? String {
            let build = (meta["appBuildVersion"] as? String).map { " (\($0))" } ?? ""
            parts.append("Variorum \(app)\(build)")
        }
        if let os = meta["osVersion"] as? String { parts.append(os) }
        return parts.isEmpty ? nil : parts.joined(separator: " \u{00B7} ")
    }
}

nonisolated struct CrashReportStore: Sendable {
    let directory: URL

    /// This Mac's folder for this app.
    static func forThisApp() -> CrashReportStore {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? FileManager.default.temporaryDirectory
        return CrashReportStore(directory: base
            .appendingPathComponent("Diagnostics", isDirectory: true)
            .appendingPathComponent("Crash Reports", isDirectory: true))
    }

    static let filePrefix = "crash-report-"
    static let fileExtension = "json"

    /// UTC, sortable, and part of the name so the list order never depends
    /// on file-system dates.
    private static func stampFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return formatter
    }

    /// Writes one report, bytes untouched. Returns nil only if the folder
    /// cannot be written (the report is then simply not kept — nothing about
    /// a failed write is ever sent anywhere either).
    @discardableResult
    func save(_ bytes: Data, receivedAt: Date, suffix: String = String(UUID().uuidString.prefix(8)))
        -> CrashReport?
    {
        let name = "\(Self.filePrefix)\(Self.stampFormatter().string(from: receivedAt))-"
            + "\(suffix.lowercased()).\(Self.fileExtension)"
        let url = directory.appendingPathComponent(name, isDirectory: false)
        do {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            try bytes.write(to: url, options: .atomic)
        } catch {
            return nil
        }
        return CrashReport(id: name, url: url, receivedAt: receivedAt, bytes: bytes)
    }

    /// Every kept report, NEWEST first. Files that are not ours are ignored.
    func list() -> [CrashReport] {
        guard let names = try? FileManager.default.contentsOfDirectory(atPath: directory.path)
        else { return [] }
        let formatter = Self.stampFormatter()
        var reports: [CrashReport] = []
        for name in names
        where name.hasPrefix(Self.filePrefix) && name.hasSuffix(".\(Self.fileExtension)") {
            let stampText = name.dropFirst(Self.filePrefix.count).prefix(16)
            guard let receivedAt = formatter.date(from: String(stampText)) else { continue }
            let url = directory.appendingPathComponent(name, isDirectory: false)
            guard let bytes = try? Data(contentsOf: url) else { continue }
            reports.append(CrashReport(id: name, url: url, receivedAt: receivedAt, bytes: bytes))
        }
        return reports.sorted {
            $0.receivedAt == $1.receivedAt ? $0.id > $1.id : $0.receivedAt > $1.receivedAt
        }
    }

    func delete(_ report: CrashReport) {
        try? FileManager.default.removeItem(at: report.url)
    }
}
