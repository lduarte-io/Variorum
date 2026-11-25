//
//  PhoneMetrics.swift
//  Variorum (Shared — the phone layer's metrics)
//
//  VM-49's brain (the VM-47 run, batch 1): the sizing sheet's §B and §C as
//  constants — one spacing scale, the screen gutter, two radii, four row
//  minimums, the 44 pt touch minimum, and the ONE helper that gives a
//  control its 44 × 44 hit area without changing its drawn size. Constants
//  and the helper only; applying them to the phone's controls is batch 2's
//  (VM-50, VM-49's application). PROVISIONAL as a set with the sheet's other
//  numbers (P-47-1).
//
//  Audit G §4.1 found 19 padding values, 12 stack gaps and 7 corner radii in
//  the phone's views and no row that declares a height; these replace them
//  as the screens adopt the scale.
//

import SwiftUI

nonisolated enum PhoneMetrics {
    // MARK: The spacing scale (sheet §C)

    /// Eight steps. The sheet's uses: 4 between a title and its second line;
    /// 8 between chips, and between a header and its first row; 12 inside
    /// buttons and capsules, a row's top and bottom; 16 between unrelated
    /// items in a row, inside cards; 20 the screen gutter; 24 above a section
    /// header, between groups; 32 between a masthead and the first content;
    /// 48 the air under the last row, empty-state air.
    enum Space {
        static let s4: CGFloat = 4
        static let s8: CGFloat = 8
        static let s12: CGFloat = 12
        static let s16: CGFloat = 16
        static let s20: CGFloat = 20
        static let s24: CGFloat = 24
        static let s32: CGFloat = 32
        static let s48: CGFloat = 48
    }

    /// The scale in order — the only padding and gap values a phone screen
    /// uses once it adopts it.
    static let spacingScale: [CGFloat] = [
        Space.s4, Space.s8, Space.s12, Space.s16,
        Space.s20, Space.s24, Space.s32, Space.s48,
    ]

    /// The screen gutter, left and right, on every screen — the one gutter
    /// (the note's 15 pt text inset and the lists' 8 + 12 both become it).
    static let gutter: CGFloat = Space.s20

    // MARK: Radii

    /// **The Mac's own two corners** (VM-273, the VM-260 run's batch 2 — her
    /// "not matching the mac's app of having more squares"; S-260-3). They were
    /// 6 and 12, with every chip a capsule. PROVISIONAL as a set (P-260-2a).
    enum Radius {
        /// A chip's corner — the Mac's near-square chip (`QuietFill.corner`, her
        /// "very subtle and square"): chips, the bar's chip, small marks.
        static let small: CGFloat = 4
        /// A box's corner — the Mac's toast, cards and fields: fields, the calm
        /// button, cards, the message line's card.
        static let standard: CGFloat = 8
        // No control is a capsule any more. The keyboard bar's glass keeps its
        // own (her ruled strip, R22/R25), and sheets wear the system's corner.
    }

    // MARK: Row minimums (rows grow with the text size; these are floors)

    enum RowHeight {
        /// A menu row, one line.
        static let menu: CGFloat = 44
        /// A row with an accessory (a tag with its remove, a menu row with
        /// a glyph).
        static let accessory: CGFloat = 52
        /// A title and one meta line (a book row).
        static let titleAndMeta: CGFloat = 64
        /// A title and two preview lines (a Library note row).
        static let titleAndPreview: CGFloat = 88
    }

    // MARK: Touch (sheet §B)

    /// Every control answers a touch across at least this, both ways. The
    /// drawn shape may be smaller; the hit area may not.
    static let touchMinimum: CGFloat = 44

    /// **The helper's arithmetic:** the hit area a control of a given drawn
    /// size gets — at least `touchMinimum` each way, never smaller than the
    /// control itself.
    static func hitArea(for drawn: CGSize) -> CGSize {
        CGSize(width: max(drawn.width, touchMinimum), height: max(drawn.height, touchMinimum))
    }

    /// How far a control's hit area reaches past its drawn edge on each side
    /// (equal on both sides of an axis) — the form a UIKit control's
    /// `point(inside:with:)` uses.
    static func hitOutset(for drawn: CGSize) -> (horizontal: CGFloat, vertical: CGFloat) {
        let area = hitArea(for: drawn)
        return ((area.width - drawn.width) / 2, (area.height - drawn.height) / 2)
    }
}

extension View {
    /// **The one hit-area helper:** a control answers a touch across at least
    /// 44 × 44 pt, centred on what it draws, without changing what it draws.
    /// Its layout frame grows to the hit area (hit areas may touch; drawn
    /// shapes keep their own size), and the whole frame is the target.
    ///
    /// Apply it to the control's LABEL (inside the `Button`), so the
    /// button's own hit-testing sees the grown frame.
    func phoneHitArea(alignment: Alignment = .center) -> some View {
        frame(
            minWidth: PhoneMetrics.touchMinimum, minHeight: PhoneMetrics.touchMinimum,
            alignment: alignment)
            .contentShape(Rectangle())
    }
}
