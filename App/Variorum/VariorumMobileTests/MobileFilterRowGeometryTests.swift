//
//  MobileFilterRowGeometryTests.swift
//  VariorumMobileTests
//
//  **THE FILTER ROW'S WIDTH, MEASURED OFF THE REAL SURFACE** (the Library
//  filter batch, 2026-08-31 — her #92(b): *"everything stays on one visible
//  row"*, with the width budget giving at the SORT).
//
//  The design record's flagged risk for this batch was WIDTH: the row grew from
//  three doors to five while she declined horizontal scrolling, so the proof
//  owed is frames-in-bounds plus no clipped door — the 4.5d discipline, whose
//  whole lesson is that *a width pin must read the surface's own width, never a
//  literal, and must read each door in the SURFACE's coordinate space, never in
//  the container that is itself overflowing.*
//
//  Everything below is taken from the accessibility frames of a row hosted in a
//  real `UIWindow` at a chosen width — the same technique
//  `MobileKeyboardBarGeometryTests` uses on the keyboard bar, adapted to a
//  SwiftUI surface where the doors are accessibility elements rather than
//  `UIButton`s.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - The real-surface host, at a chosen width

/// A view hosted in a real window of a chosen WIDTH, settled, with its
/// accessibility elements' frames readable in the host's own coordinates.
///
/// **Visible, never key** — the measured choice `withHostedBar` makes and
/// states: nothing here activates a control or presents an alert, so key
/// status buys nothing and costs the risk that file records.
@MainActor
private struct HostedRow<Content: View> {
    let window: UIWindow
    let host: UIHostingController<Content>

    /// Every accessibility element on the surface, paired with its frame.
    ///
    /// `accessibilityFrame` is in SCREEN space; the window is created at the
    /// origin with no transform and the host fills it, so screen space and the
    /// host's own space coincide here. The pins do not take that on trust for
    /// the thing that matters: each asserts `host.view.bounds.width == width`
    /// before reading a frame, which is the 4.5d rule (*a width pin must read
    /// the surface's own width, never a literal*).
    var elements: [(label: String, frame: CGRect)] {
        HostedSurface<AnyView>.elements(of: host.view).compactMap { element in
            guard let label = element.accessibilityLabel else { return nil }
            return (label, element.accessibilityFrame)
        }
    }

    func frame(ofDoorLabelled label: String) -> CGRect? {
        elements.first { $0.label == label }?.frame
    }

    func tearDown() {
        window.isHidden = true
        window.rootViewController = nil
    }
}

@MainActor
private func withHostedRow<Content: View>(
    _ view: Content, width: CGFloat, height: CGFloat = 300,
    _ body: (HostedRow<Content>) async throws -> Void
) async rethrows {
    AccessibilityServer.armOnce()
    let host = UIHostingController(rootView: view)
    let window = UIWindow(frame: CGRect(x: 0, y: 0, width: width, height: height))
    window.rootViewController = host
    window.isHidden = false
    let hosted = HostedRow(window: window, host: host)
    defer { hosted.tearDown() }
    for _ in 0..<20 {
        try? await Task.sleep(for: .milliseconds(20))
        await Task.yield()
        window.setNeedsLayout()
        window.layoutIfNeeded()
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()
    }
    try await body(hosted)
}

/// **A SAMPLE of the widths the app can be shown at, narrowest first** — the
/// same three the brief named and the same reasoning
/// `MobileKeyboardBarGeometryTests` recorded: **320 is not a device, it is
/// Display Zoom** (any modern iPhone reports it when its owner turns on larger
/// text and icons) and is the only width where a fit rule changes anything;
/// 375 is the narrowest hardware still running iOS 26 (SE 2/3, 12/13 mini);
/// 402 is an ordinary modern phone, and hers. 393 (the harness default) sits
/// between them.
private let measuredWidths: [CGFloat] = [320, 375, 402]

/// The AX sizes the row is measured at. `Font.system(size:)` scales with
/// Dynamic Type in SwiftUI, so the chrome font really does grow here — which
/// is exactly why the row is measured rather than assumed.
private let measuredTypeSizes: [DynamicTypeSize] = [
    .large, .xxxLarge, .accessibility1, .accessibility3, .accessibility5,
]

// MARK: - Reading frames off the REAL surface (the cold review's M1)

/// **The same frame reader, over `HostedSurface`** — the harness that mounts
/// the app's own views.
///
/// M1's finding, in one sentence: every geometry pin in this file measured a
/// hand-built stand-in for the sort door, so a ruling about the SHIPPED
/// door's width rested on a substitution. The component cases stay (they are
/// the cheap ones and they trip on a future door), and the fit law now also
/// runs over the real `MobileLibraryView`, whose sort door is a real
/// SwiftUI `Menu`.
@MainActor
extension HostedSurface {
    /// `accessibilityFrame` is SCREEN space; `HostedSurface` builds its window
    /// at the origin with no transform and the host fills it, so screen space
    /// and the host's own space coincide. The pins assert
    /// `host.view.bounds.width == width` before reading a frame either way —
    /// the 4.5d rule.
    func frame(ofDoorLabelled label: String) -> CGRect? {
        visibleElements.first { $0.accessibilityLabel == label }?.accessibilityFrame
    }

    /// Every element as `label @ minX…maxX (w×h)` — the dump a later session
    /// re-runs to get these numbers again.
    var frameDump: [String] {
        visibleElements.compactMap { element in
            guard let label = element.accessibilityLabel else { return nil }
            let frame = element.accessibilityFrame
            return "\(label)=\(Int(frame.minX))…\(Int(frame.maxX))"
                + "(w\(String(format: "%.1f", frame.width)))"
        }
    }
}

// MARK: - The pins

@MainActor
@Suite("Mobile filter row — width, measured on the real surface", .serialized)
struct MobileFilterRowGeometryTests {

    /// A row in the Library's shape: five doors and the sort glyph.
    private func libraryRow(
        typeSize: DynamicTypeSize = .large, voice: VoiceTokens = .terminalLight
    ) -> some View {
        MobileFilterRow(
            doors: MobileListingFilter.libraryDoors,
            selection: .all,
            tokens: voice,
            select: { _ in },
            trailing: {
                Image(systemName: MobileSortDoor.symbol)
                    .font(voice.small)
                    .foregroundStyle(voice.accent)
                    .accessibilityLabel(MobileSortDoor.label(sortWord: "last touched"))
            })
            .frame(maxHeight: .infinity, alignment: .top)
            .dynamicTypeSize(typeSize)
    }

    /// The Dynamic-Type CONTROL, and it is why the AX rows in the record can
    /// be believed. The chrome font is `Font.system(size: 11.5)`, which is
    /// FIXED in SwiftUI (only text styles and `.custom(…, relativeTo:)`
    /// scale) — so the filter row measures identically at every AX size, and
    /// an unchanging measurement is indistinguishable from a harness that
    /// never applied the setting at all. This control is a `Text` under the
    /// SAME `.dynamicTypeSize`, through the SAME HARNESS — a second window
    /// built by `withHostedRow`, not literally the same tree as the row (the
    /// cold review's n9: the earlier wording overstated it, and the
    /// experiment is real either way) — in a font that DOES scale; when it
    /// grows and the doors do not, the doors' constancy is a fact about the
    /// font rather than about the harness.
    private static let controlLabel = "dynamic type control"

    private func typeSizeControl(_ typeSize: DynamicTypeSize) -> some View {
        Text("Bookless")
            .font(.body)
            .lineLimit(1)
            .fixedSize()
            .accessibilityLabel(Self.controlLabel)
            .frame(maxHeight: .infinity, alignment: .top)
            .dynamicTypeSize(typeSize)
    }

    /// **THE MEASUREMENT ITSELF, dumped for the record.** Not an assertion
    /// harness: a reader of the batch record should be able to see the numbers
    /// that decided the spacing, and a later session should be able to re-run
    /// one test to get them again.
    @Test func theRowsMeasurementsAreOnTheRecord() async throws {
        var lines: [String] = []
        for width in measuredWidths {
            for typeSize in measuredTypeSizes {
                await withHostedRow(libraryRow(typeSize: typeSize), width: width) { row in
                    let doors = MobileListingFilter.libraryDoors.compactMap { door in
                        row.frame(ofDoorLabelled: door.word).map { (door.word, $0) }
                    }
                    let sort = row.frame(
                        ofDoorLabelled: MobileSortDoor.label(sortWord: "last touched"))
                    let widest = doors.map(\.1.maxX).max() ?? 0
                    lines.append(
                        "\(Int(width)) pt · \(typeSize): "
                        + doors.map { "\($0.0)=\(Int($0.1.minX))…\(Int($0.1.maxX))" }
                            .joined(separator: " ")
                        + " sort=\(sort.map { "\(Int($0.minX))…\(Int($0.maxX))" } ?? "—")"
                        + " rightmost=\(Int(max(widest, sort?.maxX ?? 0)))")
                }
            }
        }
        for typeSize in measuredTypeSizes {
            await withHostedRow(typeSizeControl(typeSize), width: 402) { row in
                let frame = row.frame(ofDoorLabelled: Self.controlLabel)
                lines.append(
                    "control · \(typeSize): width=\(frame.map { Int($0.width) } ?? -1)")
            }
        }
        print("FILTER-ROW-GEOMETRY\n" + lines.joined(separator: "\n"))
        #expect(!lines.isEmpty)
    }

    /// **THE FIT LAW: every door of the Library's row lands WHOLLY inside the
    /// surface, in BOTH voices, at every width the app can be shown at — and
    /// the sort glyph with them.** Her #92(b), in the only form that can be
    /// checked: *"everything stays on one visible row"*.
    ///
    /// **Both halves of the 4.5d lesson are obeyed.** The width is read from
    /// the HOST (`host.view.bounds.width == width` is asserted first, because
    /// the defect that lesson came from hid inside a pin whose toolbar was not
    /// the width it reasoned about), and each door is read in the SURFACE's
    /// coordinates — not inside the row, where every door fits by construction
    /// because the row is the thing that would overflow.
    ///
    /// **Honest label: NEW COVERAGE, not a red-on-old pin.** There is no
    /// pre-fix tree to revert to — the row grew from three doors to five in
    /// this batch, and the three-door row fit trivially. What makes it real
    /// rather than decorative is that it FAILS on the plausible alternative:
    /// at `doorSpacing` 13 (the first value tried) the 320 pt row overflows its
    /// content width, SwiftUI shrinks `Bookless` to 46 pt against its 57 pt
    /// ideal, and the scaled label drops 1.33 pt out of the row's baseline band
    /// — so the last assertion here goes red too. Both reds are quoted in the
    /// batch record; the measurement is what chose 11.
    @Test func everyFilterDoorLandsWhollyInsideTheSurfaceAtEveryWidth() async throws {
        for voice in [VoiceTokens.terminalLight, .studyLight] {
            for width in measuredWidths {
                try await withHostedRow(libraryRow(voice: voice), width: width) { row in
                    // The surface really IS the width this case is about.
                    #expect(row.host.view.bounds.width == width)

                    for door in MobileListingFilter.libraryDoors {
                        guard let frame = row.frame(ofDoorLabelled: door.word) else {
                            Issue.record("""
                                the \(door.word) door does not render at \
                                \(Int(width)) pt — labels were \
                                \(row.elements.map(\.label))
                                """)
                            continue
                        }
                        #expect(frame.width > 0, "\(door.word) renders with no width")
                        #expect(frame.minX >= -0.5,
                                "\(door.word) hangs off the left of a \(Int(width)) pt surface at x=\(frame.minX)")
                        #expect(frame.maxX <= width + 0.5,
                                "\(door.word) hangs off the right of a \(Int(width)) pt surface, ending at \(frame.maxX)")
                    }

                    // The sort glyph is a door too, and it is the one at the
                    // squeezed end of the row.
                    let sort = try #require(
                        row.frame(ofDoorLabelled: MobileSortDoor.label(sortWord: "last touched")),
                        "the sort glyph does not render at \(Int(width)) pt")
                    #expect(sort.width > 0)
                    #expect(sort.maxX <= width + 0.5,
                            "the sort glyph is cut off a \(Int(width)) pt surface, ending at \(sort.maxX)")

                    // And the doors keep their order left to right — a row
                    // that fits by re-flowing would pass everything above.
                    let xs = MobileListingFilter.libraryDoors
                        .compactMap { row.frame(ofDoorLabelled: $0.word)?.minX }
                    #expect(xs == xs.sorted(), "the doors re-flowed at \(Int(width)) pt: \(xs)")
                    #expect(sort.minX > (xs.last ?? 0), "the sort glyph is not last")

                    // ONE row: every door shares one baseline band. (A wrap
                    // would drop a door onto a second line while every
                    // assertion above still held.)
                    let ys = MobileListingFilter.libraryDoors
                        .compactMap { row.frame(ofDoorLabelled: $0.word)?.minY }
                    #expect((ys.max() ?? 0) - (ys.min() ?? 0) <= 1,
                            """
                            a door left the row's one baseline band at \
                            \(Int(width)) pt — a wrap, or a door SHRUNK to \
                            fit (a scaled label sits a little lower): \(ys)
                            """)
                }
            }
        }
    }

    /// **NOTHING IS SHRUNK TO MAKE IT FIT — measured, at the narrowest width
    /// the app is ever shown at.** `minimumScaleFactor(0.7)` is the row's
    /// degradation road, deliberately kept for a future longer word or a voice
    /// change; this pin holds that it is NOT SPENT today, so a door added
    /// without a measurement announces itself here rather than quietly
    /// rendering her chrome at 80% on Display Zoom.
    ///
    /// The oracle is each door's own ideal width, taken from the SAME surface
    /// at 402 pt — never a literal (the 4.5d rule), so a font or wording change
    /// moves both sides together.
    @Test func noFilterDoorIsShrunkToFitEvenAtDisplayZoom() async throws {
        var ideal: [MobileListingFilter: CGFloat] = [:]
        await withHostedRow(libraryRow(), width: 402) { row in
            for door in MobileListingFilter.libraryDoors {
                ideal[door] = row.frame(ofDoorLabelled: door.word)?.width
            }
        }
        try await withHostedRow(libraryRow(), width: 320) { row in
            for door in MobileListingFilter.libraryDoors {
                let atZoom = try? #require(row.frame(ofDoorLabelled: door.word)?.width)
                let wide = try? #require(ideal[door])
                guard let atZoom, let wide else { continue }
                #expect(abs(atZoom - wide) <= 0.5,
                        """
                        \(door.word) renders \(atZoom) pt at 320 against its \
                        \(wide) pt ideal — the row is spending its scale \
                        factor, so re-measure the spacing
                        """)
            }
        }
    }

    /// **THE SORT DOOR IS A GLYPH, AND THE MEASUREMENT IS THE RULING** — her
    /// #92(b): *"the width budget gives at the SORT — it shrinks to a glyph"*.
    ///
    /// A ruling about WIDTH can only be held by a width, so this reads the
    /// door's real frame off the Library's real row rather than asserting that
    /// some `Image` exists. The old text door said `sort: last touched` —
    /// 17 characters of 11.5 pt monospaced chrome, and up to 27 under
    /// `last meaningful edit` — which is what had to leave the row for five
    /// doors to fit.
    ///
    /// **RED ON OLD by behavioural revert:** put the shipped `Text(tokens
    /// .chromeLabel("sort: …"))` back as the `Menu`'s label and the door
    /// measures ~106 pt against the 30 pt bound below. (Its accessibility
    /// label is unchanged by that revert — the modifier overrides the composed
    /// one either way — which is exactly why a LABEL pin could not see this
    /// and a WIDTH pin can.)
    @Test func theSortDoorMeasuresAsAGlyphRatherThanASentence() async throws {
        let longestWord = MobileLibraryViewModel.sortOptions
            .map(MobileLibraryViewModel.sortWord)
            .max { $0.count < $1.count } ?? "last touched"
        for width in measuredWidths {
            try await withHostedRow(libraryRow(), width: width) { row in
                let sort = try #require(
                    row.frame(ofDoorLabelled: MobileSortDoor.label(sortWord: "last touched")))
                #expect(sort.width <= 30,
                        """
                        the sort door measures \(sort.width) pt at \(Int(width)) pt \
                        — #92(b) shrank it to a glyph, and the longest stamp \
                        word it used to draw is "\(longestWord)"
                        """)
            }
        }
    }

    /// **THE ARCHIVE ROOM'S ROW FITS TOO — and it is narrower by two doors,
    /// so it fits by a margin rather than by luck.** The room renders the SAME
    /// component; what differs is the door set (`archiveDoors`), and the reason
    /// is §0's model fact rather than a width budget.
    @Test func theArchiveRoomsRowFitsAtEveryWidth() async throws {
        for width in measuredWidths {
            let row = MobileFilterRow(
                doors: MobileListingFilter.archiveDoors, selection: .all,
                tokens: .terminalLight, select: { _ in })
                .frame(maxHeight: .infinity, alignment: .top)
            try await withHostedRow(row, width: width) { hosted in
                #expect(hosted.host.view.bounds.width == width)
                for door in MobileListingFilter.archiveDoors {
                    let frame = try #require(hosted.frame(ofDoorLabelled: door.word))
                    #expect(frame.minX >= -0.5)
                    #expect(frame.maxX <= width + 0.5)
                }
                // And the doors that cannot act are not merely unselectable —
                // they do not render (P-2). Asserted HERE as well as in the
                // behaviour suite, because a width pin that walked a row with
                // phantom doors would be measuring the wrong row.
                let labels = hosted.elements.map(\.label)
                #expect(!labels.contains(MobileListingFilter.books.word))
                #expect(!labels.contains(MobileListingFilter.bookless.word))
                #expect(!labels.contains(MobileListingFilter.scraps.word))
            }
        }
    }

    // MARK: - THE REAL SURFACE (the cold review's M1)

    /// A real Library, ready to host: the app's own view over real models,
    /// with the shelf model driven the way the app drives it (its held loop
    /// belongs to the shelf root's `.task`, so a harness mounting the Library
    /// alone must start it — the fact is written at `MobileLibraryView.books`).
    @MainActor
    private struct RealLibrary {
        let view: MobileLibraryView<EmptyView>
        let observing: Task<Void, Never>
    }

    private func realLibrary(_ session: AppSession) async -> RealLibrary {
        let library = MobileLibraryViewModel(session: session)
        let scraps = MobileScrapsModel(session: session)
        let stars = MobileStarsModel(session: session)
        let shelf = MobileShelfViewModel(session: session)
        let observing = Task { await shelf.start() }
        await shelf.refreshTags()
        return RealLibrary(
            view: MobileLibraryView(
                model: library, scraps: scraps, stars: stars, books: shelf,
                tokens: .terminalLight, tabBar: { EmptyView() },
                onOpen: { _ in }, onOpenTrash: {}, onOpenArchive: {}),
            observing: observing)
    }

    /// **THE FIT LAW, OVER THE SHIPPED DOOR** — the cold review's M1.
    ///
    /// Every case above measures `MobileFilterRow` with a hand-built `Image`
    /// standing in for the sort door. The SHIPPED door is
    /// `MobileLibraryView.sortMenu` — a SwiftUI **`Menu`**, which is a
    /// different UIKit thing entirely and may report a different (larger) hit
    /// region than a bare glyph. Her #92(b) is a WIDTH ruling, so its proof
    /// must not rest on a substitution: this case hosts the REAL
    /// `MobileLibraryView` at the narrowest width the app is ever shown at
    /// and reads the real Menu's own frame.
    ///
    /// **What it holds, and each is the real thing:** the row fits (nothing
    /// hangs off either edge), the doors keep their order and their one
    /// baseline band, the sort door is LAST — and **nothing is shrunk**, the
    /// oracle being each door's own width on the same real surface at 402 pt
    /// (never a literal — the 4.5d rule, so a font or wording change moves
    /// both sides together). Her ruling is fit-WITHOUT-shrink, so a real
    /// element large enough to spend `minimumScaleFactor` would be a real
    /// defect and would fail here.
    ///
    /// **RED ON OLD by a PRODUCTION revert — and naming which, because M1's
    /// whole finding is that the batch's own RED ON OLD (2) did not.** Put
    /// the shipped text door back as the `Menu`'s label in
    /// `MobileLibraryView.sortMenu` (production, not this file) and this case
    /// fails with FIVE issues at 320 pt: the real door measures 44 pt against
    /// its 78.3 pt ideal, `Bookless` collapses 57 → 34.7 and `Scraps` 42.7 →
    /// 39 as the row spends its scale factor, and a shrunken label leaves the
    /// one baseline band. **Under that same revert the three component cases
    /// above stay GREEN** — they measure a hand-built `Image`, which the
    /// production edit never touches. That contrast IS the finding, and it is
    /// quoted in the batch record.
    ///
    /// **The reviewer's speculative tail is FALSIFIED by the measurement:** a
    /// SwiftUI `Menu` labelled by a glyph reports a **16 pt** accessibility
    /// frame here, not a ≥44 pt hit region, so the shipped row was never
    /// spending its scale factor and no layout fix was owed.
    @Test func theRealLibrarysRowFitsWithoutShrinkingAtDisplayZoom() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                _ = try ops.createPost(title: "A note")
                _ = try ops.createReading(name: "Poems", kind: .book)
            }
            let sortLabel = MobileSortDoor.label(
                sortWord: MobileLibraryViewModel.sortWord(.lastTouched))
            let measured = MobileListingFilter.libraryDoors.map(\.word) + [sortLabel]
            var dump: [String] = []

            // The ideal widths, off the REAL surface at an ordinary width.
            var ideal: [String: CGFloat] = [:]
            let wide = await realLibrary(session)
            defer { wide.observing.cancel() }
            try await withHostedSurface(
                wide.view, size: CGSize(width: 402, height: 852)
            ) { surface in
                await surface.settle(50)
                #expect(surface.host.view.bounds.width == 402)
                for label in measured {
                    ideal[label] = surface.frame(ofDoorLabelled: label)?.width
                }
                dump.append("402 pt · real: " + surface.frameDump
                    .filter { line in measured.contains { line.hasPrefix("\($0)=") } }
                    .joined(separator: " "))
            }

            // And the law, at Display Zoom.
            let narrow = await realLibrary(session)
            defer { narrow.observing.cancel() }
            try await withHostedSurface(
                narrow.view, size: CGSize(width: 320, height: 852)
            ) { surface in
                await surface.settle(50)
                #expect(surface.host.view.bounds.width == 320)
                dump.append("320 pt · real: " + surface.frameDump
                    .filter { line in measured.contains { line.hasPrefix("\($0)=") } }
                    .joined(separator: " "))
                // **m6's measurement, kept because it is the reason a
                // property was deleted rather than adopted:** the row carried
                // an `accessibilityIdentifier` claiming *"the identifier the
                // geometry pins find this row by"*, and nothing ever found
                // anything by it. This prints `[]` — a container's identifier
                // never reaches the accessibility tree — so a row-level frame
                // bound was never available, and the doors are what get
                // measured. If this ever prints a non-empty list, the claim
                // becomes buildable again.
                let identifiers = surface.visibleElements
                    .compactMap { ($0 as? UIAccessibilityIdentification)?.accessibilityIdentifier }
                    .filter { !$0.isEmpty }
                dump.append("identifiers on the real surface: \(identifiers)")

                for label in measured {
                    let frame = try #require(
                        surface.frame(ofDoorLabelled: label),
                        "the \(label) door does not render on the real Library at 320 pt")
                    #expect(frame.width > 0, "\(label) renders with no width")
                    #expect(frame.minX >= -0.5,
                            "\(label) hangs off the left of the real 320 pt surface at x=\(frame.minX)")
                    #expect(frame.maxX <= 320.5,
                            "\(label) hangs off the right of the real 320 pt surface, ending at \(frame.maxX)")
                    // NOTHING IS SHRUNK — her ruling is fit-without-shrink,
                    // and the real trailing element is the one that could
                    // spend the row's scale factor.
                    let wideWidth = try #require(ideal[label])
                    #expect(abs(frame.width - wideWidth) <= 0.5,
                            """
                            \(label) renders \(frame.width) pt on the real \
                            Library at 320 against its \(wideWidth) pt ideal — \
                            the shipped row is spending its scale factor
                            """)
                }

                let xs = MobileListingFilter.libraryDoors
                    .compactMap { surface.frame(ofDoorLabelled: $0.word)?.minX }
                #expect(xs == xs.sorted(), "the real row re-flowed at 320 pt: \(xs)")
                let sort = try #require(surface.frame(ofDoorLabelled: sortLabel))
                #expect(sort.minX > (xs.last ?? 0), "the real sort door is not last")
                let ys = MobileListingFilter.libraryDoors
                    .compactMap { surface.frame(ofDoorLabelled: $0.word)?.minY }
                    + [sort.minY]
                #expect((ys.max() ?? 0) - (ys.min() ?? 0) <= 1,
                        "a door left the real row's one baseline band at 320 pt: \(ys)")

                // **AND THE SHIPPED DOOR IS A GLYPH, not a sentence** —
                // #92(b) measured where it actually lives. The bound is the
                // longest stamp word's own cost: the text door drew up to
                // "sort: last meaningful edit", and the component case's 30 pt
                // bound is repeated here against the REAL element rather than
                // the stand-in.
                #expect(sort.width <= 30,
                        """
                        the SHIPPED sort door measures \(sort.width) pt at \
                        320 pt — #92(b) shrank it to a glyph, and the longest \
                        stamp word it used to draw is \
                        "\(MobileLibraryViewModel.sortWord(.lastMajorRevision))"
                        """)
            }
            print("REAL-FILTER-ROW-GEOMETRY\n" + dump.joined(separator: "\n"))
        }
    }

    /// **DYNAMIC TYPE MOVES THE HARNESS, AND THE CHROME FONT DOES NOT MOVE
    /// WITH IT** — the honest reading of the AX rows in the record.
    ///
    /// `VoiceTokens.small` is `Font.system(size: 11.5)`, which is FIXED in
    /// SwiftUI (only text styles and `.custom(…, relativeTo:)` scale), so the
    /// filter row measures identically at `.large` and at `.accessibility5`.
    /// An unchanging measurement is worthless on its own — it is exactly what a
    /// harness that never applied the setting would produce — so this pin
    /// proves the setting IS applied by measuring a control in the same hosted
    /// tree that DOES scale, and only then asserts the row's constancy.
    ///
    /// *(That the app's chrome does not honour Dynamic Type is a real standing
    /// tension with MobileSoul §5.6 — it is PRE-EXISTING for every chrome
    /// string on this app, not this batch's doing, and it is recorded for her
    /// rather than changed here.)*
    @Test func theChromeFontDoesNotScaleAndTheHarnessProvesItIsAsking() async throws {
        var controlWidths: [CGFloat] = []
        for typeSize in measuredTypeSizes {
            await withHostedRow(typeSizeControl(typeSize), width: 402) { row in
                if let frame = row.frame(ofDoorLabelled: Self.controlLabel) {
                    controlWidths.append(frame.width)
                }
            }
        }
        #expect(controlWidths.count == measuredTypeSizes.count)
        // The control really grows — so the setting reaches the hosted tree.
        #expect((controlWidths.last ?? 0) > (controlWidths.first ?? 0) * 2,
                "the Dynamic Type setting is not reaching the host: \(controlWidths)")

        var doorWidths: [[CGFloat]] = []
        for typeSize in measuredTypeSizes {
            await withHostedRow(libraryRow(typeSize: typeSize), width: 320) { row in
                doorWidths.append(
                    MobileListingFilter.libraryDoors.compactMap {
                        row.frame(ofDoorLabelled: $0.word)?.width
                    })
            }
        }
        #expect(doorWidths.count == measuredTypeSizes.count)
        for widths in doorWidths {
            #expect(widths == doorWidths[0],
                    "the chrome font moved with Dynamic Type: \(doorWidths)")
        }
    }
}
