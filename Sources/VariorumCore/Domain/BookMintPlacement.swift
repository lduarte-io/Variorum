//
//  BookMintPlacement.swift
//  VariorumCore
//
//  VX-1039 (the VX-1036 run, batch 1 — the design record's N-2, her R-1036-8:
//  "i agree with this") — **WHERE A NOTE MADE INSIDE A BOOK IS BORN.** A
//  chapter's own "+" makes it in that chapter, at its end; the general doors
//  (the navigator foot, the page foot, ⌥⌘N) make it after the note she is on,
//  in that note's chapter; with no note to stand beside, at the end — the
//  place every door used before this rule. Under a stamp order the place is
//  the order's: the book shows the note where its order puts it, and the
//  position written here still says "after the note she was on" for any
//  reader of the hand order (a look on a hand-ordered book leaves the stored
//  order manual).
//
//  PURE: the door hands what the book's page shows (each note's chapter and
//  pin, in the order drawn — `Queries.assembleReading`'s one ORDER BY) and
//  gets back an anchor in the book's one position list plus the chapter the
//  membership points at — `Operations.newPostInReading(_:section:…at:)`'s two
//  arguments, AppSpec §9's existing vocabulary. Who "the note she is on" is
//  (live or selected, else the navigator's viewed note — PROVISIONAL, named in
//  the design record's §4f) is the door's question; this rule only answers
//  where a note goes beside it.
//
//  The pin float (VX-803 — pinned notes sort ahead of the rest within their
//  chapter): a new note is born unpinned, so "after" a PINNED note means the
//  first unpinned slot of that chapter — right before its first unpinned
//  note, or its end when it has none. Under a stamp order nothing about the
//  drawn sequence is the hand order, so the anchor is the note itself.
//

import Foundation

public enum BookMintPlacement {
    /// One note as the book's page shows it.
    public struct Shown: Equatable, Sendable {
        public let postID: String
        /// The live chapter it is drawn under (nil = unfiled, or a book
        /// without chapters) — the assembly's own `section_id`.
        public let sectionID: String?
        public let pinned: Bool

        public init(postID: String, sectionID: String?, pinned: Bool) {
            self.postID = postID
            self.sectionID = sectionID
            self.pinned = pinned
        }
    }

    /// Which door is minting.
    public enum Door: Equatable, Sendable {
        /// A chapter's own "+": that chapter, at its end.
        case chapter(String)
        /// The navigator foot, the page foot, ⌥⌘N — beside the note she is on
        /// (nil: none).
        case general(onNote: String?)
    }

    /// Where in the book's one position list.
    public enum Anchor: Equatable, Sendable {
        case end
        case after(String)
        case before(String)
    }

    public struct Placement: Equatable, Sendable {
        public let anchor: Anchor
        /// The chapter the membership points at (nil = unfiled).
        public let sectionID: String?

        public init(anchor: Anchor, sectionID: String?) {
            self.anchor = anchor
            self.sectionID = sectionID
        }

        /// Every door's place before this rule: the end, in no chapter.
        public static let end = Placement(anchor: .end, sectionID: nil)
    }

    /// **The rule.** `shown` is the book as its page draws it, in order;
    /// `manualOrder` is whether that drawn order IS the hand order (no stamp
    /// order stored, no look picked).
    public static func placement(for door: Door, shown: [Shown], manualOrder: Bool) -> Placement {
        switch door {
        case .chapter(let sectionID):
            return Placement(anchor: .end, sectionID: sectionID)
        case .general(onNote: nil):
            return .end
        case .general(onNote: let noteID?):
            guard let index = shown.firstIndex(where: { $0.postID == noteID }) else {
                // A note the page does not show (it left the book, or the
                // window) stands beside nothing: the end.
                return .end
            }
            let on = shown[index]
            guard manualOrder, on.pinned else {
                return Placement(anchor: .after(on.postID), sectionID: on.sectionID)
            }
            // A pinned note: the first unpinned slot of its chapter.
            let firstUnpinned = shown[(index + 1)...].first {
                $0.sectionID == on.sectionID && !$0.pinned
            }
            return Placement(
                anchor: firstUnpinned.map { .before($0.postID) } ?? .end,
                sectionID: on.sectionID)
        }
    }
}
