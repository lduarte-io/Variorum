//
//  MobileSpaceEaterTests.swift
//  VariorumMobileTests
//
//  13u2 UNIT D — item 2, "the eager space-eater", the PHONE's half.
//
//  Her words name both apps: *"it's really annoying in both variorum and
//  variorum mobile when you typed a space but are sitting there thinking of a
//  word and the program eagerly eats your space"*. The mechanism is the same
//  one the Mac's `SpaceEaterTests` traces, because the brain is the same:
//  `MobileEditorViewModel.idleMintTail` plans
//  `CrystallizationPlanner.kindForDurabilityMint` over the open tail, and the
//  `.idle` plan's segments used to lose the trailing space of the piece under
//  her caret. The fix lives in `Shared/EditorBrain/CrystallizationPlanner`, so
//  the phone inherits it with no phone-side arm — and this pin is what proves
//  the phone's own road really lands it.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Item 2 — the eager space-eater (the phone's durability mint)")
struct MobileSpaceEaterTests {
    @Test func typingASpaceAndPausingKeepsItOnTheSurfaceAndInTheStore() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "space", profile: .blog)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            // A fresh note is all tail — mid-thought typing, nothing minted.
            typeAtEnd(model, storage, "the quick brown ")
            // The 2 s clock never fires under test; fire the tick it would.
            model.idleMintTail()
            await model.awaitMintSettle()

            // RED ON OLD: both read "the quick brown".
            #expect(storage.string == "the quick brown ")
            let stored = try await storedBlockTexts(db, postID: post.id)
            #expect(stored == ["the quick brown "])
        }
    }

    @Test func aPastedLineStillTrimsOnThePhone() async throws {
        // PRESERVED behaviour (green on both trees): bulk entry is untouched.
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "paste", profile: .blog)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()

            typeAtEnd(model, storage, "pasted line \nand another \n", isPaste: true)
            model.idleMintTail()
            await model.awaitMintSettle()

            let stored = try await storedBlockTexts(db, postID: post.id)
            #expect(stored == ["pasted line", "and another"])
        }
    }
}
