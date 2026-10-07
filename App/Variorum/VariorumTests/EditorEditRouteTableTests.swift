//
//  EditorEditRouteTableTests.swift
//  VariorumTests
//
//  **18m U1 — THE ORDER ITSELF, PINNED** (the thing that was untestable
//  before: the cross-block ladder's arm set and order lived as prose-argued
//  `if/else` inside two view models, reachable only through a mounted
//  editor — the post-13u health review §2.1, leak 1). The route is now one
//  pure decision over declared data (`Shared/EditorBrain/EditorEditRoute
//  .swift`), so every pin here runs with no store, no AppKit, no timing —
//  the index, the projection, a string-backed surface.
//
//  These are NEW-BEHAVIOR pins for the table (the API they drive is new).
//  The ROUTE-EQUIVALENCE claim — that each gate still answers every
//  keystroke exactly as its ladder did — rides the UNMODIFIED existing pins
//  on both platforms (`SeamMergeTests`, `WholeBlockDeleteTests`,
//  `BoundaryClampTests`, `CrossBlockCompoundTests`, the find fence's pins,
//  the phone's `MobileCrossBlockEditTests` / `MobileWholeBlockDeleteTests`).
//
//  The ORDER-BITES pins drive shapes TWO declared arms both plan, assert the
//  claimant, and assert that a PERMUTED list answers differently — so the
//  order is provably the thing pinned, never a coincidence of exclusive
//  geometry.
//

import Foundation
import Testing
import VariorumCore

@testable import Variorum

@Suite("The cross-block route's declared order (18m U1)")
struct EditorEditRouteTableTests {
    typealias Arm = EditorEditRoute.Arm
    typealias Route = EditorEditRoute.Route

    // MARK: - Fixtures (pure: slots → index + a string-backed surface)

    /// A note as the gate sees it: the projection, the tiling built from it
    /// (optionally over MORE slots than the projection holds — O-3's shape),
    /// and the surface text it tiles.
    struct Note {
        let slots: [Queries.RenderedBlock]
        let tail: String?
        /// The slots the INDEX tiles; `slots` is the projection the gate
        /// holds beside it (the two differ only where a pin says so).
        let tiled: [Queries.RenderedBlock]

        init(_ slots: [Queries.RenderedBlock], tail: String? = nil,
             projection: [Queries.RenderedBlock]? = nil) {
            self.tiled = slots
            self.slots = projection ?? slots
            self.tail = tail
        }

        var index: BlockRangeIndex { BlockRangeIndex(slots: tiled, tail: tail) }

        var document: String {
            var text = tiled.map { $0.text ?? "" }.joined(separator: EditorDocument.separator)
            if let tail {
                if !tiled.isEmpty { text += EditorDocument.separator }
                text += tail
            }
            return text
        }

        /// Routes one proposed edit; `reads` counts the live-surface reads
        /// (the ruling's condition 1 — bounded, read-only).
        func route(
            _ range: NSRange, _ replacement: String = "",
            arms: [Arm], findReplacing: Bool = false
        ) -> (route: Route, reads: Int) {
            let surface = document as NSString
            var reads = 0
            let route = EditorEditRoute.route(
                range: range, replacement: replacement,
                index: index, slots: slots,
                findReplacing: findReplacing,
                arms: arms,
                surfaceText: { range in
                    reads += 1
                    return surface.substring(with: range)
                })
            return (route, reads)
        }
    }

    /// "Alpha one.\nBeta two.\nGamma three." — A=[0,10) sep 10, B=[11,20)
    /// sep 20, C=[21,33).
    static let three = Note([
        slot("b0", text: "Alpha one."),
        slot("b1", text: "Beta two."),
        slot("b2", text: "Gamma three."),
    ])

    /// Which arm a route names (nil = the terminal diagnosis).
    static func arm(of route: Route) -> Arm? {
        switch route {
        case .refuseFindReplace: .findReplaceFence
        case .carveEmptyBlock: .emptyBlockCarve
        case .mergeTextedSeam: .textedSeamMerge
        case .deleteWholeBlocks: .wholeBlockDelete
        case .editInBlock: .clampedInBlockEdit
        case .refuseAwaitingSync: .gapFence
        case .editAcrossBlocks: .crossBlockCompound
        case .refuse: nil
        }
    }

    static let mac = EditorEditRoute.macArms
    static let phone = EditorEditRoute.phoneArms

    // MARK: - The declared lists, as data

    @Test func theTwoDeclaredListsArePinnedLiterally() {
        #expect(EditorEditRoute.macArms == [
            .findReplaceFence, .emptyBlockCarve, .textedSeamMerge,
            .wholeBlockDelete, .clampedInBlockEdit, .crossBlockCompound,
        ])
        #expect(EditorEditRoute.phoneArms == [
            .wholeBlockDelete, .clampedInBlockEdit, .gapFence, .crossBlockCompound,
        ])
    }

    /// The Mac gate walks the Mac's list (the phone's twin pin lives in the
    /// mobile target, `MobileEditRouteArmsTests`).
    @MainActor
    @Test func theMacGateWalksTheMacsDeclaredList() {
        #expect(EditorViewModel.routeArms == EditorEditRoute.macArms)
    }

    /// **THE CAPABILITY DIFFERENCES, AS DECLARED FACTS** — not drift. The
    /// phone lacks the find fence (no find-and-replace in its editor) and
    /// BOTH seam carves (KnownIssues row 51, deliberately unbuilt); the Mac
    /// lacks the gap fence's COPY arm (its diagnosis's `.unsyncedBlock`
    /// speaks for that condition). Everything else is one list's and the
    /// other's alike, and no arm exists that neither platform declares.
    @Test func theCapabilityDifferencesAreDeclaredFacts() {
        let mac = Set(Self.mac)
        let phone = Set(Self.phone)
        #expect(mac.subtracting(phone) == [.findReplaceFence, .emptyBlockCarve, .textedSeamMerge])
        #expect(phone.subtracting(mac) == [.gapFence])
        #expect(mac.intersection(phone) == [.wholeBlockDelete, .clampedInBlockEdit, .crossBlockCompound])
        #expect(mac.union(phone) == Set(Arm.allCases), "no arm is declared by neither platform")
        #expect(Self.mac.count == mac.count && Self.phone.count == phone.count, "no arm twice")
    }

    // MARK: - The ruled precedence

    @Test func bothListsHonourEveryRuledPrecedence() {
        #expect(EditorEditRoute.violations(of: Self.mac).isEmpty,
                "\(EditorEditRoute.violations(of: Self.mac).map(\.ruling))")
        #expect(EditorEditRoute.violations(of: Self.phone).isEmpty,
                "\(EditorEditRoute.violations(of: Self.phone).map(\.ruling))")
        for rule in EditorEditRoute.precedence {
            #expect(!rule.ruling.isEmpty, "every constraint names its ruling")
            #expect(rule.before != rule.after)
        }
        // Ladder round 1 (the NIT, 2026-09-29): the fence's GENERATED rows
        // cover the PLANNER arms only. The gap fence is a COPY arm — it can
        // only refuse (O-2) — so L6's "the safety core runs before every
        // planner" has nothing to guard there, and no ruling has ever placed
        // the two relative to each other (no platform declares both). A row
        // claiming L6 for that pair would be an extrapolation wearing a
        // ruling's name, against the table's own promise.
        #expect(!EditorEditRoute.precedence.contains {
            $0.before == .findReplaceFence && $0.after == .gapFence
        }, "the fence's generated rows pair it with planner arms only")
    }

    /// **An ABSENT arm is a VACUOUS PASS — and the rule BITES the day it
    /// arrives** (the ruling's condition 2). "The carves ≺ J9" holds on
    /// today's phone list because the phone has no carves; the day row 51's
    /// catch-up adds them, a wrong position fails BY NAME.
    @Test func anAbsentArmPassesVacuouslyAndTheRuleBitesWhenItArrives() {
        #expect(!Self.phone.contains(.emptyBlockCarve))
        #expect(EditorEditRoute.violations(of: Self.phone).isEmpty, "vacuous today")

        // Row 51 built WRONG — the carve appended below J9.
        let wrong = Self.phone + [.emptyBlockCarve]
        let broken = EditorEditRoute.violations(of: wrong)
        #expect(broken.contains { $0.before == .emptyBlockCarve && $0.after == .wholeBlockDelete },
                "the carves ≺ J9 rule bites")
        #expect(broken.contains { $0.before == .emptyBlockCarve && $0.after == .clampedInBlockEdit })

        // Row 51 built RIGHT — both carves at the head, A7 first.
        let right: [Arm] = [.emptyBlockCarve, .textedSeamMerge] + Self.phone
        #expect(EditorEditRoute.violations(of: right).isEmpty)

        // …and the Mac's list is not vacuously compliant: swap J9 and the
        // clamp and her stated order is named as broken.
        var swapped = Self.mac
        swapped.swapAt(swapped.firstIndex(of: .wholeBlockDelete)!,
                       swapped.firstIndex(of: .clampedInBlockEdit)!)
        #expect(EditorEditRoute.violations(of: swapped)
            .contains { $0.before == .wholeBlockDelete && $0.after == .clampedInBlockEdit })
    }

    // MARK: - Input shape × the arm that must claim it, per platform

    /// **A lone separator beside an EMPTY block** — A7's geometry. The Mac
    /// carves it; the phone has no carve, so every arm declines and the
    /// diagnosis speaks (row 51's honest refusal).
    @Test func aLoneEmptySeparatorIsTheMacsCarveAndThePhonesRefusal() {
        let note = Note([slot("b0", text: "alpha"), slot("b1", text: ""), slot("b2", text: "beta")])
        let seam = NSRange(location: 5, length: 1)
        #expect(note.route(seam, arms: Self.mac).route
            == .carveEmptyBlock(.init(blockID: "b1", variantID: "v-b1", entryIndex: 1)))
        #expect(note.route(seam, arms: Self.phone).route == .refuse(.seamKeystrokeDeclined))
    }

    /// **A lone separator between two TEXTED blocks** — #34's geometry.
    @Test func aTextedSeamIsTheMacsMergeAndThePhonesRefusal() {
        let note = Note([slot("b0", text: "alpha"), slot("b1", text: "beta")])
        let seam = NSRange(location: 5, length: 1)
        #expect(note.route(seam, arms: Self.mac).route
            == .mergeTextedSeam(.init(
                leadingIndex: 0, trailingIndex: 1, leadingBlockID: "b0", trailingBlockID: "b1")))
        #expect(note.route(seam, arms: Self.phone).route == .refuse(.seamKeystrokeDeclined))
    }

    /// **A7's REAL guards, through the route** — the (c1) point: the carve
    /// declines on a fan, an archived take, a comment, and the diagnosis
    /// names which. A FANNED TEXTED seam is still #34's: the fan is the
    /// executor's store read, never the plan's.
    @Test func theCarvesOwnGuardsDeclineAndTheDiagnosisNamesWhy() {
        let seam = NSRange(location: 5, length: 1)
        func beside(_ empty: Queries.RenderedBlock) -> Note {
            Note([slot("b0", text: "alpha"), empty])
        }
        #expect(beside(slot("b1", text: "", fan: 2)).route(seam, arms: Self.mac).route
            == .refuse(.seamBesideFan))
        #expect(beside(slot("b1", text: "", archived: 1)).route(seam, arms: Self.mac).route
            == .refuse(.seamBesideArchivedTake))
        #expect(beside(slot("b1", text: "", comments: 1)).route(seam, arms: Self.mac).route
            == .refuse(.seamBesideComment))
        #expect(beside(slot("b1", text: "", locked: true)).route(seam, arms: Self.mac).route
            == .refuse(.lockedTake))

        let fannedTexted = Note([slot("b0", text: "alpha", fan: 2), slot("b1", text: "beta")])
        #expect(Self.arm(of: fannedTexted.route(seam, arms: Self.mac).route) == .textedSeamMerge,
                "#34's plan never asks about the fan — its executor reads the store")
    }

    /// **O-3, seeded deliberately:** a seam beside a block the PROJECTION has
    /// not echoed yet (`slots` shorter than the tiling) — A7 declines on its
    /// bounds guard and the diagnosis says the keystroke could not join.
    @Test func aCarveBesideAnUnprojectedBlockDeclinesToTheSeamKeystrokeCause() {
        let tiled = [slot("b0", text: "alpha"), slot("b1", text: "")]
        let note = Note(tiled, projection: [tiled[0]])
        #expect(note.route(NSRange(location: 5, length: 1), arms: Self.mac).route
            == .refuse(.seamKeystrokeDeclined))
    }

    /// **A whole paragraph plus its newline, deleted** — J9 on both.
    @Test func aWholeBlockRunIsTheDeleteOnBothPlatforms() {
        let span = NSRange(location: 11, length: 10)
        #expect(Self.three.route(span, arms: Self.mac).route == .deleteWholeBlocks(["b1"]))
        #expect(Self.three.route(span, arms: Self.phone).route == .deleteWholeBlocks(["b1"]))
    }

    /// **One block plus its separator, TYPED OVER** — J9 declines a
    /// type-over, so #109's clamp takes it on both.
    @Test func oneBlockPlusItsSeparatorTypedOverIsTheClampOnBothPlatforms() {
        let span = NSRange(location: 11, length: 10)
        let expected = Route.editInBlock(.init(
            range: NSRange(location: 11, length: 9), entryIndex: 1, blockID: "b1",
            replacement: "Fresh.", expectedText: "Beta two.", documentLength: 33))
        #expect(Self.three.route(span, "Fresh.", arms: Self.mac).route == expected)
        #expect(Self.three.route(span, "Fresh.", arms: Self.phone).route == expected)
    }

    /// **THE SHIELD BEHIND `CrossBlockRefusal.diagnose`'s HARDCODED
    /// `isDeletion: true`** (VM-5 stability pass, NIT 5). The terminal
    /// diagnosis is handed no replacement and reads every lone inter-entry
    /// separator as a seam DELETE. That is true only because a TYPE-OVER of
    /// a lone separator never reaches it: #109's clamp answers every one
    /// (its degenerate shape — QUESTIONS #111) with a zero-length in-block
    /// edit, on BOTH declared lists. This pins that claim over every
    /// inter-entry separator of a note mixing texted, EMPTY (both edges of a
    /// run of two) and fanned blocks, under an open tail — so an arm-list
    /// edit that ever lets one through fails here BY NAME instead of making
    /// the diagnosis' deletion reading silently false (its comment says what
    /// to do then). A guard pin: green before and after the NIT's change,
    /// which is a comment naming this shield, not a behaviour change.
    @Test func aLoneSeparatorTypedOverNeverReachesTheDiagnosis() {
        let note = Note([
            slot("b0", text: "alpha"), slot("b1", text: ""), slot("b2", text: ""),
            slot("b3", text: "beta", fan: 2), slot("b4", text: "gamma"),
        ], tail: "open")
        let index = note.index
        let ranges = index.entryRanges()
        for k in 0..<(ranges.count - 1) {
            let seam = NSRange(location: ranges[k].upperBound, length: 1)
            #expect(index.interEntrySeparatorPair(deleting: seam, isDeletion: true) != nil,
                    "precondition: \(seam) is an inter-entry separator")
            for (name, arms) in [("mac", Self.mac), ("phone", Self.phone)] {
                let claimed = note.route(seam, "x", arms: arms).route
                #expect(Self.arm(of: claimed) == .clampedInBlockEdit,
                        "\(name): typing over the separator at \(seam.location) is the clamp's, never the diagnosis'")
            }
        }
    }

    /// **Mid-paragraph to mid-paragraph** — the compound on both, with the
    /// shared planner's own answer.
    @Test func aMidToMidSpanIsTheCompoundOnBothPlatforms() throws {
        let span = NSRange(location: 6, length: 10)
        let surface = Self.three.document as NSString
        let plan = try #require(CrossBlockCompound.plan(
            replacing: span, with: "", index: Self.three.index,
            surfaceText: { surface.substring(with: $0) }))
        #expect(plan.leading?.blockID == "b0" && plan.trailing?.blockID == "b1" && plan.joinsEnds)
        #expect(Self.three.route(span, arms: Self.mac).route == .editAcrossBlocks(plan))
        #expect(Self.three.route(span, arms: Self.phone).route == .editAcrossBlocks(plan))
    }

    /// **A whole run holding a block that has not ARRIVED** — the phone's
    /// COPY arm speaks its read-only line; the Mac's diagnosis names the
    /// same condition (the words differ — O-1, U3's).
    @Test func aWholeRunWithAGapIsThePhonesCopyArmAndTheMacsDiagnosis() {
        let note = Note([slot("b0", text: "Alpha one."), slot("b1", text: nil),
                         slot("b2", text: "Gamma three.")])
        let all = NSRange(location: 0, length: note.index.documentLength)
        #expect(note.route(all, arms: Self.phone).route == .refuseAwaitingSync)
        #expect(note.route(all, arms: Self.mac).route == .refuse(.unsyncedBlock))
    }

    /// **The find fence** — a machine-driven sweep over a carve-shaped seam
    /// refuses on the Mac; with no sweep, the carve answers. The phone's list
    /// cannot fire the fence even if the fact were true (the ruling's
    /// condition 6 — the phone passes `false` besides).
    @Test func aFindSweepIsFencedOnTheMacAndThePhonesListCannotFireIt() {
        let note = Note([slot("b0", text: "alpha"), slot("b1", text: ""), slot("b2", text: "beta")])
        let seam = NSRange(location: 5, length: 1)
        #expect(note.route(seam, arms: Self.mac, findReplacing: true).route == .refuseFindReplace)
        #expect(Self.arm(of: note.route(seam, arms: Self.mac, findReplacing: false).route)
                == .emptyBlockCarve)
        #expect(note.route(seam, arms: Self.phone, findReplacing: true).route
                == note.route(seam, arms: Self.phone, findReplacing: false).route)
    }

    // MARK: - ORDER BITES: two arms plan the same shape; the list decides

    /// **J9 ≺ clamp** (her stated order): a whole paragraph plus its newline
    /// plus Delete is ALSO a clamp plan (it would empty the block in place).
    /// The declared list sends it to the tray; a permuted list would not.
    /// And the claim is LAZY: J9 answers before the clamp ever reads the
    /// surface.
    @Test func wholeBlockDeleteOutranksTheClampOnAShapeBothPlan() {
        let span = NSRange(location: 11, length: 10)
        #expect(Self.arm(of: Self.three.route(span, arms: [.clampedInBlockEdit]).route)
                == .clampedInBlockEdit, "the clamp plans this shape too — the overlap is real")

        let declared = Self.three.route(span, arms: Self.mac)
        #expect(declared.route == .deleteWholeBlocks(["b1"]))
        #expect(declared.reads == 0, "LAZY — the clamp never ran, so it never read the surface")

        var permuted = Self.mac
        permuted.swapAt(permuted.firstIndex(of: .wholeBlockDelete)!,
                        permuted.firstIndex(of: .clampedInBlockEdit)!)
        #expect(Self.arm(of: Self.three.route(span, arms: permuted).route) == .clampedInBlockEdit,
                "the ORDER is what decided it")
    }

    /// **J9 ≺ the compound** (#33(a)'s unrestricted delete above R-13u-1's
    /// refuse-whole compound): deleting the whole note is ALSO a compound
    /// plan that deletes every block — under a different undo label and a
    /// lock refusal J9 does not have.
    @Test func wholeBlockDeleteOutranksTheCompoundOnAShapeBothPlan() {
        let all = NSRange(location: 0, length: 33)
        #expect(Self.arm(of: Self.three.route(all, arms: [.crossBlockCompound]).route)
                == .crossBlockCompound, "the compound plans this shape too")
        #expect(Self.three.route(all, arms: Self.phone).route == .deleteWholeBlocks(["b0", "b1", "b2"]))
        #expect(Self.three.route(all, arms: Self.mac).route == .deleteWholeBlocks(["b0", "b1", "b2"]))
        #expect(Self.arm(of: Self.three.route(
            all, arms: [.crossBlockCompound, .wholeBlockDelete]).route) == .crossBlockCompound)
    }

    /// **The find fence ≺ everything** (the safety core): a sweep over a
    /// shape a carve would take refuses; the fence listed below the carve
    /// would let the sweep delete a block.
    @Test func theFindFenceOutranksTheCarveItGuards() {
        let note = Note([slot("b0", text: "alpha"), slot("b1", text: ""), slot("b2", text: "beta")])
        let seam = NSRange(location: 5, length: 1)
        #expect(note.route(seam, arms: Self.mac, findReplacing: true).route == .refuseFindReplace)
        let permuted: [Arm] = [.emptyBlockCarve, .findReplaceFence]
            + Self.mac.filter { $0 != .emptyBlockCarve && $0 != .findReplaceFence }
        #expect(Self.arm(of: note.route(seam, arms: permuted, findReplacing: true).route)
                == .emptyBlockCarve)
    }

    /// **The gap fence is a COPY arm** (O-2, adopted): with or without it the
    /// gesture REFUSES — J9 and the compound each decline a gap run on their
    /// own fences — and only the words change.
    @Test func theGapFenceChangesOnlyTheWords() {
        let note = Note([slot("b0", text: "Alpha one."), slot("b1", text: nil),
                         slot("b2", text: "Gamma three.")])
        let all = NSRange(location: 0, length: note.index.documentLength)
        #expect(note.route(all, arms: Self.phone).route == .refuseAwaitingSync)
        let withoutIt = Self.phone.filter { $0 != .gapFence }
        #expect(note.route(all, arms: withoutIt).route == .refuse(.unsyncedBlock),
                "still a refusal — nothing lands either way")
    }

    // MARK: - Properties over every small edit

    /// **Across every short range of four small notes, both replacements,
    /// both fence facts:** a platform is only ever answered by an arm it
    /// DECLARES (so its view model's undeclared-arm cases are unreachable),
    /// and one route reads the live surface AT MOST TWICE (the ruling's
    /// condition 1 — the old ladder's own bound).
    @Test func aPlatformIsOnlyAnsweredByAnArmItDeclaresAndReadsAreBounded() {
        let notes = [
            Self.three,
            Note([slot("b0", text: "alpha"), slot("b1", text: ""), slot("b2", text: "beta")]),
            Note([slot("b0", text: "Alpha one."), slot("b1", text: nil),
                  slot("b2", text: "Gamma three.")]),
            Note([slot("b0", text: "ab"), slot("b1", text: "cd", fan: 2)], tail: "ef"),
        ]
        var routed = 0
        for note in notes {
            let length = note.index.documentLength
            for location in 0...length {
                for span in 0...min(12, length - location) {
                    let range = NSRange(location: location, length: span)
                    guard note.index.verdict(
                        replacing: range, replacementIsSingleNewline: false,
                        segmentation: .paragraph) == .refuse(.crossesBlockBoundary)
                    else { continue }
                    for replacement in ["", "X"] {
                        for fence in [false, true] {
                            for (name, arms) in [("mac", Self.mac), ("phone", Self.phone)] {
                                let (route, reads) = note.route(
                                    range, replacement, arms: arms, findReplacing: fence)
                                routed += 1
                                if let arm = Self.arm(of: route) {
                                    #expect(arms.contains(arm),
                                            "\(name) answered by undeclared \(arm) at \(range)")
                                }
                                #expect(reads <= 2, "\(name) read the surface \(reads)× at \(range)")
                            }
                        }
                    }
                }
            }
        }
        #expect(routed > 100, "non-vacuous: \(routed) cross-block edits routed")
    }
}
