//
//  strings-workbook-mint — BRANCH-ONLY (`tools/strings-workbook`, never merges;
//  GitHub issue #5). The author's own copy-pass instrument: mints ONE book,
//  "App Strings", into HER library so she can rewrite the Mac app's copy in
//  her own app. Never linked into any app; never on a release road.
//  The record: notes/plans/strings-workbook-record.md.
//
//  Run from the repo root (the inventory paths default to notes/copy-pass/):
//
//    swift run -c release strings-workbook-mint --plan-only
//    swift run -c release strings-workbook-mint --store <path> --dry-run
//    swift run -c release strings-workbook-mint --store <path>
//
//  Flags:
//    --store <path>             the library's variorum.sqlite (must exist; its
//                               key file must sit beside it). Required unless
//                               --plan-only.
//    --strings <path>           default notes/copy-pass/all-user-facing-strings.md
//    --priority <path>          default notes/copy-pass/priority-order.md
//    --plan-only                parse and plan; print the shape; touch no store
//    --dry-run                  unlock and probe; print what would be minted;
//                               write nothing
//    --recovery-words           unlock with the twelve words instead of the
//                               passphrase (prompted, no echo)
//    --passphrase-file <path>   rehearsal input: the file's bytes are the
//                               passphrase (one trailing newline stripped;
//                               never printed). --recovery-file likewise.
//    --yes                      skip the typed MINT confirmation (rehearsals)
//
//  The secret is read with echo OFF and lives only in this process's memory;
//  no Keychain item is read or written. Refuses while any Variorum app
//  instance runs (the zero-instance window is the mint's precondition).
//

import AppKit
import Darwin
import Foundation
import StringsWorkbook
import VariorumCore

@main
enum StringsWorkbookMintCLI {
    static func main() {
        do {
            try run()
        } catch let error as Usage {
            FileHandle.standardError.write(Data("\(error.description)\n".utf8))
            exit(2)
        } catch {
            FileHandle.standardError.write(Data("strings-workbook-mint: REFUSED — \(error)\n".utf8))
            exit(1)
        }
    }

    struct Usage: Error, CustomStringConvertible {
        var description: String {
            """
            usage: strings-workbook-mint --plan-only
                   strings-workbook-mint --store <path/to/variorum.sqlite> [--dry-run]
                       [--recovery-words] [--strings <md>] [--priority <md>]
                       [--passphrase-file <path> | --recovery-file <path>] [--yes]
            """
        }
    }

    struct Refusal: Error, CustomStringConvertible {
        let description: String
    }

    static func say(_ line: String) {
        print("strings-workbook-mint: \(line)")
    }

    static func run() throws {
        let arguments = CommandLine.arguments
        func value(of flag: String) -> String? {
            guard let index = arguments.firstIndex(of: flag), index + 1 < arguments.count else { return nil }
            return arguments[index + 1]
        }
        let planOnly = arguments.contains("--plan-only")
        let dryRun = arguments.contains("--dry-run")
        let useWords = arguments.contains("--recovery-words") || value(of: "--recovery-file") != nil
        let skipConfirm = arguments.contains("--yes")
        let stringsPath = value(of: "--strings") ?? "notes/copy-pass/all-user-facing-strings.md"
        let priorityPath = value(of: "--priority") ?? "notes/copy-pass/priority-order.md"
        let storePath = value(of: "--store")
        guard planOnly || storePath != nil else { throw Usage() }

        // 1. The plan — parsed, checked against the inventory's own counts.
        let inventory = try StringsInventory.parse(try String(contentsOfFile: stringsPath, encoding: .utf8))
        let tiers = try TierPlan.tiers(fromPriorityDoc: try String(contentsOfFile: priorityPath, encoding: .utf8))
        let plan = try WorkbookPlan.make(inventory: inventory, tiers: tiers)
        let corrected = inventory.surfaces.flatMap(\.bullets).filter(\.correctedFromSource).count
        say("inventory: \(inventory.bulletCount) strings in \(inventory.surfaces.count) surfaces — every footer and the Totals table agree")
        say("  \(corrected) literals carry ⏎ and take their verified source text (the record's F-1)")
        say("plan: book “\(WorkbookPlan.bookName)” · \(plan.chapters.count) chapters · \(plan.notes.count) notes · \(plan.blockCount) blocks · \(plan.blockCount * 3) takes")
        for chapter in plan.chapters {
            let blocks = chapter.notes.reduce(0) { $0 + $1.blocks.count }
            say("  \(chapter.name) — \(chapter.notes.count) notes, \(blocks) blocks")
        }
        if planOnly { say("--plan-only: no store touched."); return }

        // 2. The zero-instance window.
        let running = ["io.lduarte.Variorum", "io.lduarte.Variorum.debug"].flatMap {
            NSRunningApplication.runningApplications(withBundleIdentifier: $0)
        }
        guard running.isEmpty else {
            throw Refusal(description: "a Variorum app is running (\(running.compactMap(\.bundleIdentifier).joined(separator: ", "))) — quit it first; the mint needs a zero-instance window")
        }

        // 3. The store, its key file, its local roads — no secret yet.
        let storeURL = URL(fileURLWithPath: (storePath! as NSString).expandingTildeInPath)
        try StoreUnlock.requireExistingEncryptedStore(at: storeURL)
        let roads = try StoreUnlock.localRoads(besideStore: storeURL)
        say("store: \(storeURL.path)")
        say("  key file: \(roads.keyFile.lastPathComponent) — passphrase copy: \(roads.passphrase ? "yes" : "NO") · recovery-words copy: \(roads.recoveryWords ? "yes" : "NO")")

        // 4. The secret (echo off), the unwrap.
        let key: StoreKey
        if useWords {
            let text = try secret(file: value(of: "--recovery-file"), prompt: "Your twelve recovery words (hidden): ")
            key = try StoreUnlock.key(besideStore: storeURL, recoveryText: text)
        } else {
            let typed = try secret(file: value(of: "--passphrase-file"), prompt: "Encryption passphrase (hidden): ")
            say("deriving the key (a second or two)…")
            key = try StoreUnlock.key(besideStore: storeURL, passphrase: typed)
        }
        say("  unlocked.")

        // 5. The probe: schema identical to this build's, workbook absent.
        let probe = try StoreUnlock.probe(storeAt: storeURL, key: key)
        say("  schema matches this build (\(probe.migrations.count) migrations, last \(probe.migrations.last ?? "—")) · \(probe.books) books · \(probe.notes) notes")
        if let existing = probe.existingWorkbook {
            throw WorkbookMint.MintError.alreadyMinted(existingName: existing)
        }
        say("  no “\(WorkbookPlan.bookName)” book yet.")
        if dryRun { say("--dry-run: nothing written. Would mint \(plan.blockCount) blocks into the book above."); return }

        // 6. Her typed go.
        if !skipConfirm {
            print("Type MINT to write the workbook into this library (anything else stops): ", terminator: "")
            guard readLine(strippingNewline: true) == "MINT" else {
                say("stopped — nothing written.")
                return
            }
        }

        // 7. The mint, the read-back, the clean close.
        let (database, binding) = try StoreUnlock.open(storeAt: storeURL, key: key)
        let started = Date()
        let report: WorkbookMint.Report
        do {
            report = try WorkbookMint.mint(plan, into: database) { done, total in
                if done % 250 == 0 || done == total { say("  minted \(done)/\(total) blocks") }
            }
            try WorkbookMint.verify(plan, readingID: report.readingID, in: database)
        } catch {
            let close = binding.lock()
            say("the pool closed \(close.closedCleanly ? "cleanly" : "with a failure: \(close.closeFailure ?? "?")")")
            throw error
        }
        let elapsed = Int(Date().timeIntervalSince(started))
        let close = binding.lock()
        say("minted: 1 book · \(report.chapters) chapters · \(report.notes) notes · \(report.blocks) blocks · \(report.takes) takes in \(elapsed)s")
        say("verified: every chapter, note, block and take re-read from the store matches the plan.")
        say("store closed \(close.closedCleanly ? "cleanly" : "WITH A FAILURE: \(close.closeFailure ?? "?")").")
        say("next: open Variorum — “\(WorkbookPlan.bookName)” is on the Bookcase, unshelved (top of All).")
    }

    /// A secret from a rehearsal file (one trailing newline stripped) or the
    /// terminal with echo OFF. Never printed.
    static func secret(file: String?, prompt: String) throws -> String {
        if let file {
            guard var text = try? String(contentsOfFile: file, encoding: .utf8) else {
                throw Refusal(description: "cannot read the secret file at \(file)")
            }
            if text.hasSuffix("\n") { text.removeLast() }
            return text
        }
        var buffer = [CChar](repeating: 0, count: 4096)
        guard let raw = readpassphrase(prompt, &buffer, buffer.count, RPP_ECHO_OFF | RPP_REQUIRE_TTY) else {
            throw Refusal(description: "could not read from the terminal (run it in Terminal, not piped)")
        }
        let typed = String(cString: raw)
        buffer.withUnsafeMutableBufferPointer { $0.update(repeating: 0) }
        guard !typed.isEmpty else { throw Refusal(description: "nothing was typed") }
        return typed
    }
}
