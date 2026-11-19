//
//  MobilePhoneControlsSourceTests.swift
//  VariorumMobileTests
//
//  VM-50 (the VM-47 run, batch 2) — **the retired private builds stay
//  gone.** Audit G §4.4 counted five separately built calm buttons, three
//  (in fact four) field builds, ten hand-rolled sheet headers and rows of
//  plain chip-sized words standing in for segmented choices. Batch 2 moved
//  every one to the phone's one set of controls (`Shared/Theme/
//  PhoneControls.swift`); this walk of the source keeps them there.
//
//  THE SIGNATURES, over every Swift file under `VariorumMobile/` outside the
//  two debug harnesses, plus the shared pages' styling seam
//  (`Shared/Theme/SharedPageStyle.swift`), the controls' own file excluded:
//  · a sheet's own Done — `chromeLabel("Done")` (the sheet header owns it);
//  · a calm button's own padding — vertical 9/10/12 over horizontal 14/16;
//  · the old field insets — `EdgeInsets(top: 11, leading: 12, …)`;
//  · a rounded paper or card shape with an edge — `RoundedRectangle(
//    cornerRadius: 6|8|10)` filled with the surface or the card and
//    overlaid (the calm buttons' and the fields' shared build);
//  · a word-row choice — a `chip`-role word whose ink flips between ink and
//    faint by selection.
//  The CARDS that legitimately wear the paper-and-edge shape are named
//  below with their reason (the twelve-words cards, the acknowledgement
//  cards): a card is not a control.
//
//  RED ON OLD, measured with these exact patterns over the pre-batch tree
//  (`751765baf`): 11 Done literals, 4 field insets, 5 calm paddings (2 of
//  them the allowed cards), 13 paper shapes (2 the allowed cards) and 4 word
//  rows — and clean now. NEW COVERAGE that holds the adoption (a source
//  scan like `MobilePhoneTypeSourceTests`), not a defect pin.
//

import Foundation
import Testing

@Suite("Phone controls — the retired builds stay gone (VM-50)")
struct MobilePhoneControlsSourceTests {
    private static var appRoot: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
    }

    private static let excludedPrefixes = ["VariorumMobile/Spike/", "VariorumMobile/Features/Perf/"]

    /// The cards that wear the paper-and-edge shape on purpose — a card is
    /// not a control. File → how many matches of each signature it may hold.
    private static let allowedCards: [String: [String: Int]] = [
        // `pagePhraseCard`: the twelve words' one focal card.
        "Shared/Theme/SharedPageStyle.swift": ["paper shape": 1],
        // The acknowledgement cards (one per licence).
        "VariorumMobile/Features/Protection/MobileAcknowledgmentsSheet.swift": ["paper shape": 1],
        // The twelve-words cards on the Protection screen and the lock face.
        "VariorumMobile/Features/Protection/MobileProtectionScreen.swift": ["calm padding": 1],
        "VariorumMobile/Features/Protection/MobileRoadFaces.swift": ["calm padding": 1],
    ]

    private func files() -> [(relative: String, source: String)] {
        let root = Self.appRoot
        var found: [(String, String)] = []
        guard let walker = FileManager.default.enumerator(
            at: root.appendingPathComponent("VariorumMobile"), includingPropertiesForKeys: nil)
        else { return found }
        for case let url as URL in walker {
            guard url.pathExtension == "swift" else { continue }
            let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
            guard !Self.excludedPrefixes.contains(where: { relative.hasPrefix($0) }) else { continue }
            if let source = try? String(contentsOf: url, encoding: .utf8) {
                found.append((relative, source))
            }
        }
        let shared = root.appendingPathComponent("Shared/Theme/SharedPageStyle.swift")
        if let source = try? String(contentsOf: shared, encoding: .utf8) {
            found.append(("Shared/Theme/SharedPageStyle.swift", source))
        }
        return found
    }

    private static let signatures: [(name: String, pattern: String)] = [
        ("Done literal", #"chromeLabel\("Done"\)"#),
        ("calm padding", #"\.padding\(\.vertical, (?:9|10|12)\)\s*\n\s*\.padding\(\.horizontal, (?:14|16)\)"#),
        ("field insets", #"EdgeInsets\(top: 11, leading: 12, bottom: 11, trailing: 12\)"#),
        ("paper shape", #"RoundedRectangle\(cornerRadius: (?:6|8|10)\)\s*\n\s*\.fill\((?:style\.)?tokens\.(?:surface|card)\)\s*\n\s*\.overlay\("#),
        ("word-row choice", #"\.phoneType\(\.chip, tokens\)\s*\n\s*\.foregroundStyle\([^\n]*\? tokens\.ink : tokens\.phone\.faint\)"#),
    ]

    @Test func theWalkReachesThePhonesViewsAndTheSharedPages() {
        let all = files().map(\.relative)
        #expect(all.count > 60, "the walk must reach the phone's views (\(all.count) files)")
        #expect(all.contains("VariorumMobile/Features/Shell/MobileCreateBook.swift"))
        #expect(all.contains("Shared/Theme/SharedPageStyle.swift"))
        #expect(!all.contains { $0.hasSuffix("PhoneControls.swift") }, "the controls' own file is not scanned")
    }

    @Test func noPrivateButtonFieldHeaderOrWordRowBuildIsBack() throws {
        var offenders: [String] = []
        for file in files() {
            let allowed = Self.allowedCards[file.relative] ?? [:]
            for signature in Self.signatures {
                let regex = try NSRegularExpression(pattern: signature.pattern)
                let range = NSRange(file.source.startIndex..., in: file.source)
                let matches = regex.matches(in: file.source, range: range)
                let beyond = matches.count - (allowed[signature.name] ?? 0)
                guard beyond > 0 else { continue }
                for match in matches.suffix(beyond) {
                    let prefix = file.source[..<Range(match.range, in: file.source)!.lowerBound]
                    let line = prefix.split(separator: "\n", omittingEmptySubsequences: false).count
                    offenders.append("\(file.relative):\(line) — \(signature.name)")
                }
            }
        }
        #expect(offenders.isEmpty, """
            The phone has ONE set of controls (`Shared/Theme/PhoneControls.swift`, VM-50): \
            a sheet's header is `PhoneSheetHeader`, a shaped button is `PhoneCalmButtonStyle`, \
            a field is `phoneField`, a choice is `PhoneSegmentedChoice` or a filter chip. \
            A card that wears the paper shape on purpose is named in `allowedCards`.
            \(offenders.joined(separator: "\n"))
            """)
    }
}
