//
//  TutorialBuildFlavorTests.swift
//  VariorumTests
//
//  17y B-DEDUPE (the B2 ladder's MAJOR-2): the seeded guide teaches the
//  BUILD's modes — Release (no Canvas after item (p)) must never read
//  "Canvas" or "⌘7" in the getting-around sentence or carry the canvas
//  lesson; Debug keeps all seven whole. Both flavors are pinned through the
//  ONE pure pair the mint reads (`modeRowSentence`, `lookingLessonContent`),
//  the helper's own precedent (its "canvas" row gates on the same seam).
//  The class's red-on-old is the B2 ladder's own probe: the old sentence
//  was a hard-coded literal carrying "Canvas, and ⌘1 through ⌘7" in every
//  flavor (MAJOR-2's evidence); the keySpan arm below is also red against
//  that literal's "⌘1 through ⌘7" spelling.
//

import Testing

@testable import Variorum

@Suite("The guide teaches the build's modes (17y B-DEDUPE, MAJOR-2)")
struct TutorialBuildFlavorTests {

    @Test func theReleaseSentenceTeachesNoCanvas() {
        let sentence = TutorialSeeder.modeRowSentence(keepingCanvas: false)
        #expect(!sentence.contains("Canvas"))
        #expect(!sentence.contains("\u{2318}7"))
        #expect(sentence.contains("one of six modes"))
        #expect(sentence.contains(PostMode.modeList(keepingCanvas: false)))
        #expect(sentence.contains(PostMode.keySpan(keepingCanvas: false)))
    }

    @Test func theDebugSentenceKeepsAllSeven() {
        let sentence = TutorialSeeder.modeRowSentence(keepingCanvas: true)
        #expect(sentence.contains("one of seven modes"))
        #expect(sentence.contains(PostMode.modeList(keepingCanvas: true)))
        #expect(sentence.contains(PostMode.keySpan(keepingCanvas: true)))
        #expect(sentence.contains("Canvas"))
    }

    @Test func theReleaseLookingLessonIsTheWorkbenchAlone() {
        let lesson = TutorialSeeder.lookingLessonContent(teachesCanvas: false)
        #expect(lesson.title == "blocks")
        #expect(lesson.paragraphs.count == 2)
        // 13s-b triage landing — A JUSTIFIED EDIT: the modes read in their
        // real casing now (her R-13s-30 caps ban), so both arms read the
        // real-cased names; an all-caps "CANVAS" probe would pass vacuously.
        #expect(!lesson.paragraphs.contains { $0.lowercased().contains("canvas") })
        #expect(lesson.paragraphs.contains { $0.contains("Blocks (\u{2318}6)") })
    }

    @Test func theDebugLookingLessonKeepsTheCanvasWhole() {
        let lesson = TutorialSeeder.lookingLessonContent(teachesCanvas: true)
        #expect(lesson.title == "blocks \u{B7} canvas")
        #expect(lesson.paragraphs.count == 4)
        #expect(lesson.paragraphs.contains { $0.contains("Canvas (\u{2318}7)") })  // 13s-b triage landing
        #expect(lesson.paragraphs.contains { $0.contains("order by clicking") })
    }

    /// The plan and the mint read the SAME function, so the shape pins
    /// (chapters == plan, lessons == plan) hold in both flavors by
    /// construction — this arm just says so where a drift would start.
    @Test func thePlanAndTheMintShareTheLessonTitle() {
        let waysOfLooking = TutorialSeeder.plan.first { $0.chapter == "ways of looking" }
        #expect(waysOfLooking?.lessons.last == TutorialSeeder.lookingLessonContent().title)
    }
}
