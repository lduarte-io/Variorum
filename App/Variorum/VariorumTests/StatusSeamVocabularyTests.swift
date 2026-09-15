//
//  StatusSeamVocabularyTests.swift
//  VariorumTests
//
//  13u2 UNIT E — **the status seam's audit surface**
//  (`KnownIssuesAndTechDebt` row 56).
//
//  The row's finding, in one sentence: the class of a status message
//  (refusal · offer · receipt — 18i, her R-Q5) is decided AT THE DOOR, but
//  the doors were five vocabularies across ~150 sites and NONE of their names
//  said which class they made. So the 18i ladder found four mis-classified
//  families BY HAND, in three rounds, against a suite of 2,577 green tests —
//  because a call site's class is invisible to a pin that reads the words.
//
//  Step 1 renamed the always-shown doors so a call site reads its class with
//  no doc: `StatusCenter.speak` → `refuse` / `offer` / `direct`;
//  `EditorViewModel.showStatus` → `refuse` / `direct`;
//  `showTransientStatus` → `directTransiently`; the four view models' own
//  `speak` → `refuse`; `TakesViewModel.setStatus` → `setReceipt` /
//  `clearStatus`. Step 2 made `TakesViewModel.status` unwritable except
//  through those doors.
//
//  THIS FILE IS THE THIRD STEP, in the form that fits: **the retired names
//  cannot come back.** P-1's full registry walk — every classed door
//  declared, a walk asserting the class at each — is the checkable form the
//  row asks for and it is a design, not a rename; it stays the row's
//  residual, recorded with its reason. What a source walk CAN guarantee
//  today is that the vocabulary does not regrow: a future door named
//  `showStatus` or `speak` fails the suite here, loudly, with the line.
//
//  (It is a grep pin, in the `NoLiteralColourTests` shape — the house form
//  for "a rule P-8 states in words, made to fail the suite".)
//

import Foundation
import Testing

@Suite("The status seam's doors say their class (13u2 UNIT E — KnownIssues row 56)")
struct StatusSeamVocabularyTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
    }

    /// The retired spellings, each with what it became. A door that says
    /// "status" says nothing: the whole defect class is a site whose class is
    /// invisible.
    private static let retired: [String: String] = [
        "showStatus": "refuse (nothing happened) or direct (a direction, nothing refused)",
        "showTransientStatus": "directTransiently",
        "setStatus": "setReceipt (it landed) or clearStatus (clear the line before an act)",
    ]

    /// `.speak(` gets its own check, because the bare word `speak` is legal
    /// English that several unrelated doors use in their prose and in names
    /// this rename did not touch (`speakUndoHint`, the `speakCeremony…`
    /// quartet — row 56's recorded residual, named in this file's record).
    /// What must not come back is a status door CALLED as `.speak(…)`.
    private static let retiredCall = ".speak("

    /// The phone has its own private `speak(_:at:)` on `MobileStars`, which
    /// is not this seam and not this rename's (the Mac's `StatusCenter` does
    /// not exist there). Scanning the Mac app and the shared layer is exactly
    /// the seam's reach.
    private static let scannedRoots = ["Variorum", "Shared"]

    private func swiftFiles(under root: URL) -> [URL] {
        guard let walker = FileManager.default.enumerator(
            at: root, includingPropertiesForKeys: nil) else { return [] }
        return walker.compactMap { $0 as? URL }.filter { $0.pathExtension == "swift" }
    }

    /// A line is code (not a comment or a doc line) for this pin's purpose —
    /// the retired names are named in prose all over this codebase's records,
    /// deliberately, and prose is not a call site.
    private func isCode(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        return !trimmed.hasPrefix("//") && !trimmed.hasPrefix("///") && !trimmed.hasPrefix("*")
    }

    @Test func noStatusDoorIsNamedForItsPlacementInsteadOfItsClass() throws {
        var offenders: [String] = []
        var scanned = 0
        for rootName in Self.scannedRoots {
            let root = Self.appRoot.appendingPathComponent(rootName)
            #expect(FileManager.default.fileExists(atPath: root.path), "root missing: \(rootName)")
            for file in swiftFiles(under: root) {
                let relative = rootName + "/" + file.path.replacingOccurrences(
                    of: root.path + "/", with: "")
                scanned += 1
                let source = try String(contentsOf: file, encoding: .utf8)
                for (index, line) in source.split(
                    separator: "\n", omittingEmptySubsequences: false).enumerated()
                where isCode(String(line)) {
                    let text = String(line)
                    for (name, became) in Self.retired where text.contains(name) {
                        // `setStatusMessage` is `EditorViewModel`'s PRIVATE
                        // primitive, which the two classed doors above it
                        // call; it is not a door a feature can reach.
                        if name == "setStatus", text.contains("setStatusMessage") { continue }
                        offenders.append("\(relative):\(index + 1) — `\(name)` (it is `\(became)` now)")
                    }
                    if text.contains(Self.retiredCall) {
                        offenders.append(
                            "\(relative):\(index + 1) — `.speak(` (a status door is "
                            + "`refuse`, `offer`, `direct` or `receipt` now)")
                    }
                }
            }
        }
        #expect(scanned > 200, "the walk really read the app (\(scanned) files)")
        let report = offenders.joined(separator: " · ")
        #expect(offenders.isEmpty, "the status seam's retired vocabulary came back: \(report)")
    }

    /// **The board's status line has no bypass** (step 2, as a fact rather
    /// than a convention). `private(set)` was not enough: it is private to
    /// the TYPE and its same-file extensions, and that file is 2,600 lines,
    /// so 66 sites wrote the slot directly and the doors were a habit. The
    /// stored slot is `private` and `status` is a computed forward now, so
    /// `status = …` does not compile anywhere — including inside the file.
    @Test func theBoardsStatusLineIsWrittenOnlyThroughItsClassedDoors() throws {
        let file = Self.appRoot
            .appendingPathComponent("Variorum/Features/Takes/TakesViewModel.swift")
        let source = try String(contentsOf: file, encoding: .utf8)
        var offenders: [String] = []
        for (index, line) in source.split(
            separator: "\n", omittingEmptySubsequences: false).enumerated()
        where isCode(String(line)) {
            let text = String(line)
            // A write into the slot by any spelling. (`statusSlot` itself is
            // written by exactly the three doors, which this walk counts.)
            if text.contains("status = ") || text.contains("status=") {
                offenders.append("TakesViewModel.swift:\(index + 1) — \(text.trimmingCharacters(in: .whitespaces))")
            }
        }
        let report = offenders.joined(separator: " · ")
        #expect(offenders.isEmpty, "a direct write into the board's status line: \(report)")

        let slotWrites = source.split(separator: "\n").filter {
            isCode(String($0)) && $0.contains("statusSlot = ")
        }
        #expect(slotWrites.count == 3,
                "exactly three writers — setReceipt, setRefusal, clearStatus (found \(slotWrites.count))")
    }
}
