import Foundation
import Testing
@testable import VariorumCore

/// VM-2 — the keystroke fence's rule, pure (`StructuralFlightFence`). The
/// store-level pins that drive the phone's real doors through a held flight
/// are the phone's (`MobileStructuralFlightFenceTests`); these pin the rule's
/// letter: what each kind of edit gets while a flight is up, the order her
/// keys keep, when the fence may drop, and that a refusal is spoken once.
///
/// These are NEW-API pins (the type does not exist on the old tree), so they
/// cannot be red on old; the bug's red-on-old pins are the phone's.
@Suite("VM-2 — the keystroke fence around a structural flight")
struct StructuralFlightFenceTests {

    // MARK: - Open: nothing is fenced

    @Test func anOpenFencePassesEveryKindOfEdit() {
        var fence = StructuralFlightFence()
        #expect(!fence.isUp)
        let r1 = fence.offer(.insert("x"), composing: false)
        #expect(r1 == false)
        let r2 = fence.offer(.deleteBackward, composing: false)
        #expect(r2 == false)
        let r3 = fence.refusesPolicedEdit()
        #expect(r3 == false)
        let r4 = fence.withholdsSystemEdit()
        #expect(r4 == false)
        #expect(fence.deferred.isEmpty)
        #expect(!fence.owesSentence, "nothing was refused, so nothing is owed")
        let r5 = fence.drain()
        #expect(r5 == .init(replay: [], speak: false))
    }

    // MARK: - Flying: typed keys wait, in order; nothing is dropped

    @Test func typedKeysDuringAFlightAreDeferredInTheOrderPressed() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        #expect(fence.isUp)
        let r6 = fence.offer(.insert("X"), composing: false)
        #expect(r6)
        let r7 = fence.offer(.deleteBackward, composing: false)
        #expect(r7)
        let r8 = fence.offer(.insert("yz"), composing: false)
        #expect(r8)
        #expect(fence.deferred == [.insert("X"), .deleteBackward, .insert("yz")])

        let r9 = fence.flightLanded(surfaceSettled: true)

        #expect(r9 == .drain)
        let drained = fence.drain()
        #expect(drained.replay == [.insert("X"), .deleteBackward, .insert("yz")])
        #expect(!drained.speak, "a deferred key is replayed, not refused — nothing to say")
        #expect(!fence.isUp)
        #expect(fence.deferred.isEmpty)
    }

    /// The replay runs through the page's own input road, which offers each
    /// key to the fence again: by then the fence is open and its queue empty,
    /// so the replayed key passes instead of queueing behind itself.
    @Test func aReplayedKeyPassesTheFenceItCameOutOf() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        _ = fence.offer(.insert("X"), composing: false)
        _ = fence.flightLanded(surfaceSettled: true)
        for input in fence.drain().replay {
            let r10 = fence.offer(input, composing: false)
            #expect(r10 == false)
        }
    }

    @Test func aCompositionInProgressIsNeverDeferred() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        let r11 = fence.offer(.insert("か"), composing: true)
        #expect(r11 == false)
        let r12 = fence.offer(.deleteBackward, composing: true)
        #expect(r12 == false)
        #expect(fence.deferred.isEmpty,
                "marked text is the keyboard's own state — never held back from the page")
    }

    // MARK: - Refused and withheld edits leave ONE sentence

    @Test func aPolicedEditIsRefusedAndTheRefusalIsSpokenOnceAtTheLanding() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        let r13 = fence.refusesPolicedEdit()
        #expect(r13)
        let r14 = fence.refusesPolicedEdit()
        #expect(r14)
        #expect(fence.owesSentence)
        _ = fence.flightLanded(surfaceSettled: true)
        let r15 = fence.drain()
        #expect(r15.speak)
        #expect(!fence.owesSentence)

        // The next flight starts clean: a sentence is owed per refusal, not forever.
        fence.flightBegan()
        _ = fence.flightLanded(surfaceSettled: true)
        #expect(!fence.drain().speak)
    }

    @Test func aGatelessEditIsWithheldAndSpoken() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        let r16 = fence.withholdsSystemEdit()
        #expect(r16)
        _ = fence.flightLanded(surfaceSettled: true)
        let drained = fence.drain()
        #expect(drained.speak)
        #expect(drained.replay.isEmpty, "a withheld system edit is not hers to replay")
    }

    // MARK: - The fence drops only on a settled surface

    @Test func anUnsettledLandingKeepsTheFenceUpUntilTheSurfaceSettles() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        _ = fence.offer(.insert("a"), composing: false)
        let r17 = fence.flightLanded(surfaceSettled: false)
        #expect(r17 == .awaitSettle)
        #expect(fence.phase == .settling)
        #expect(fence.isUp, "the latch is down but the page still shows the old note")

        // Still fenced while settling: keys wait, other edits refuse.
        let r18 = fence.offer(.insert("b"), composing: false)
        #expect(r18)
        let r19 = fence.refusesPolicedEdit()
        #expect(r19)

        let r20 = fence.surfaceSettled()
        #expect(r20, "settling ⇒ a drain is owed")
        #expect(fence.isUp, "the fence stays up until the drain actually runs")
        let drained = fence.drain()
        #expect(drained.replay == [.insert("a"), .insert("b")])
        #expect(drained.speak)
        #expect(!fence.isUp)
    }

    @Test func aSettleReportWithNothingToWaitForOwesNoDrain() {
        var fence = StructuralFlightFence()
        let r21 = fence.surfaceSettled()
        #expect(r21 == false)
        fence.flightBegan()
        let r22 = fence.surfaceSettled()
        #expect(r22 == false, "flying is not settling — the door is still at work")
    }

    @Test func aFlightThatBeginsWhileTheLastIsSettlingTakesItOver() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        _ = fence.offer(.insert("a"), composing: false)
        _ = fence.flightLanded(surfaceSettled: false)
        fence.flightBegan()
        #expect(fence.phase == .flying)
        _ = fence.offer(.insert("b"), composing: false)
        let r23 = fence.flightLanded(surfaceSettled: true)
        #expect(r23 == .drain)
        let r24 = fence.drain()
        #expect(r24.replay == [.insert("a"), .insert("b")])
    }

    @Test func theSettleRuleNeedsNeitherAForcedRenderNorADeferredProjection() {
        #expect(StructuralFlightFence.surfaceHoldsTheStore(
            forcedRenderOwed: false, projectionDeferred: false))
        #expect(!StructuralFlightFence.surfaceHoldsTheStore(
            forcedRenderOwed: true, projectionDeferred: false))
        #expect(!StructuralFlightFence.surfaceHoldsTheStore(
            forcedRenderOwed: false, projectionDeferred: true))
        #expect(!StructuralFlightFence.surfaceHoldsTheStore(
            forcedRenderOwed: true, projectionDeferred: true))
    }
}
