//
//  BookMastheadTitleLineRuleTests.swift
//  VariorumTests
//
//  **VX-1014 — the book masthead's title line, its width rule, pure**
//  (`BookMastheadTitleLineRule`; the record is
//  `notes/plans/fixes/vx-1082-nov-24-fixes.md`, BATCH S). The mounted red-on-old
//  pins are `BookMastheadFitsItsColumnTests`; these hold the rule itself (a
//  build pin for the new Layout's arithmetic): at rest the line is the HStack
//  it replaced; open, the field keeps its shipped 90-pt floor while the column
//  can hold it, the name is whole before the field grows, the floor gives way
//  only to the room; never wider than the room the bare doors fit in; whole
//  points out of any input. The numbers are the measured ones (13-pt 🔍 and
//  gear, a 32-pt Arrivals door with a two-digit count, "Video ideas" at 89 pt
//  in Study's heading).
//

import CoreGraphics
import Testing
@testable import Variorum

@Suite("VX-1014 — the book masthead's title line, its width rule")
struct BookMastheadTitleLineRuleTests {
    typealias Rule = BookMastheadTitleLineRule

    /// The bare 🔍 (the field at rest) and the open door (the field from
    /// nothing to its 180 ceiling, beside the 🔍).
    static let resting: (min: CGFloat, max: CGFloat) = (13, 13)
    static let open: (min: CGFloat, max: CGFloat) = (17, 197)

    @Test func atRestTheLineIsTheHStacksOwn() {
        for room in [166.0, 212.0, 336.0] as [CGFloat] {
            for trailing in [[13.0], [32.0, 13.0]] as [[CGFloat]] {
                let w = Rule.widths(room: room, nameIdeal: 89, doorMin: Self.resting.min,
                                    doorMax: Self.resting.max, trailing: trailing)
                let fixed = Rule.nameGap + trailing.reduce(0) { $0 + Rule.doorGap + $1 }
                #expect(w.door == 13, "the bare 🔍 keeps its width")
                #expect(w.name == room - fixed - 13, "the name has the rest, as the Spacer gave it: \(w)")
                #expect(w.line == room)
            }
        }
    }

    @Test func theOpenFieldKeepsItsFloorWhileTheColumnCanHoldIt() {
        // The navigator's floor (190 − 24 = 166), "Video ideas", the gear.
        let w = Rule.widths(room: 166, nameIdeal: 89, doorMin: Self.open.min, doorMax: Self.open.max, trailing: [13])
        #expect(w.door == Self.open.min + Rule.fieldFloor, "the field at its 90-pt floor: \(w)")
        #expect(w.name == 166 - 27 - w.door, "the name yields the rest (truncated): \(w)")
        #expect(w.line == 166, "never wider than the room")
    }

    @Test func theNameIsWholeBeforeTheFieldGrows() {
        let middle = Rule.widths(room: 236, nameIdeal: 89, doorMin: Self.open.min, doorMax: Self.open.max, trailing: [13])
        #expect(middle.name == 89, "the name whole: \(middle)")
        #expect(middle.door == 236 - 27 - 89, "the field takes what is left above its floor: \(middle)")
        let wide = Rule.widths(room: 336, nameIdeal: 89, doorMin: Self.open.min, doorMax: Self.open.max, trailing: [13])
        #expect(wide.door == Self.open.max, "the field at its 180 ceiling: \(wide)")
        #expect(wide.name >= 89, "and the name whole beside it: \(wide)")
        let long = Rule.widths(room: 336, nameIdeal: 250, doorMin: Self.open.min, doorMax: Self.open.max, trailing: [13])
        #expect(long.door == Self.open.min + Rule.fieldFloor, "a long name keeps the field at its floor: \(long)")
        #expect(long.name == 336 - 27 - long.door)
    }

    @Test func theFloorGivesWayOnlyToTheRoom() {
        // The navigator's floor with a two-digit Arrivals count beside the gear.
        let w = Rule.widths(room: 166, nameIdeal: 89, doorMin: Self.open.min, doorMax: Self.open.max, trailing: [32, 13])
        let fixed = Rule.nameGap + Rule.doorGap + 32 + Rule.doorGap + 13
        #expect(w.door == 166 - fixed, "the field narrows to the room — under its floor only here: \(w)")
        #expect(w.name == 0, "the name has yielded everything first: \(w)")
        #expect(w.line == 166)
    }

    /// The property: for every room the bare doors fit in, the line is never
    /// wider than the room; the door never under the bare 🔍 nor over its
    /// ceiling; nothing negative; whole points out of fractional inputs.
    @Test func neverWiderThanTheRoomAndAlwaysWholePoints() {
        for room in stride(from: 0.0, through: 420.0, by: 3.25) {
            for name in [0.0, 25.5, 51, 89.4, 121, 250] as [CGFloat] {
                for trailing in [[], [13.0], [32.6, 13.2], [39.0, 13.0]] as [[CGFloat]] {
                    for door in [Self.resting, Self.open, (min: 17.4, max: 196.6)] {
                        let w = Rule.widths(room: CGFloat(room), nameIdeal: name, doorMin: door.min,
                                            doorMax: door.max, trailing: trailing)
                        let fixed = Rule.nameGap + trailing.reduce(0) { $0 + Rule.doorGap + $1.rounded(.up) }
                        let tag = "room \(room) name \(name) trailing \(trailing) door \(door): \(w)"
                        if CGFloat(room) >= fixed + door.min.rounded(.up) {
                            #expect(w.line <= CGFloat(room), "never wider than the room — \(tag)")
                        }
                        #expect(w.door >= door.min.rounded(.up) && w.door <= max(door.min.rounded(.up), door.max.rounded(.down)),
                                "the door within its own range — \(tag)")
                        #expect(w.name >= 0, "nothing negative — \(tag)")
                        #expect(w.name == w.name.rounded() && w.door == w.door.rounded() && w.line == w.line.rounded(),
                                "whole points — \(tag)")
                    }
                }
            }
        }
    }
}
