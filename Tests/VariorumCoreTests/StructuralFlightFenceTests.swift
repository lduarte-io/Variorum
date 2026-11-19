import Foundation
import Testing
@testable import VariorumCore

/// VM-2 — the keystroke fence's rule, pure (`StructuralFlightFence`). The
/// store-level pins that drive the phone's real doors through a held flight
/// are the phone's (`MobileStructuralFlightFenceTests`); these pin the rule's
/// letter: what each kind of edit gets while a flight is up, when the fence
/// may drop, and that a refusal is said once.
///
/// These are NEW-API pins (the type does not exist on the old tree), so they
/// cannot be red on old; the bug's red-on-old pins are the phone's.
@Suite("VM-2 — the keystroke fence around a structural flight")
struct StructuralFlightFenceTests {

    // MARK: - Open: nothing is fenced

    @Test func anOpenFencePassesEveryKindOfEdit() {
        var fence = StructuralFlightFence()
        #expect(!fence.isUp)
        let policed = fence.refusesPolicedEdit()
        #expect(policed == false)
        let system = fence.withholdsSystemEdit()
        #expect(system == false)
        #expect(!fence.owesSentence, "nothing was refused, so nothing is owed")
        let speak = fence.drain()
        #expect(speak == false)
    }

    // MARK: - Flying: refused and withheld edits leave ONE sentence

    @Test func anEditTheGateIsAskedAboutIsRefusedAndSaidOnceAtTheLanding() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        #expect(fence.isUp)
        let first = fence.refusesPolicedEdit()
        #expect(first)
        let second = fence.refusesPolicedEdit()
        #expect(second, "every edit asked about while up is refused — a typed key, ⌫, a paste")
        #expect(fence.owesSentence)
        let landing = fence.flightLanded(surfaceSettled: true)
        #expect(landing == .drain)
        let speak = fence.drain()
        #expect(speak, "said once, as the fence drops")
        #expect(!fence.isUp)
        #expect(!fence.owesSentence)

        // The next flight starts clean: a sentence is owed per refusal, not forever.
        fence.flightBegan()
        _ = fence.flightLanded(surfaceSettled: true)
        let quiet = fence.drain()
        #expect(quiet == false)
    }

    @Test func aGatelessEditIsWithheldAndSaid() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        let withheld = fence.withholdsSystemEdit()
        #expect(withheld)
        _ = fence.flightLanded(surfaceSettled: true)
        let speak = fence.drain()
        #expect(speak)
    }

    @Test func aFlightWithNothingRefusedDropsSilently() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        let landing = fence.flightLanded(surfaceSettled: true)
        #expect(landing == .drain)
        let speak = fence.drain()
        #expect(speak == false, "a door that met no edit says nothing more than its own receipt")
        #expect(!fence.isUp)
    }

    // MARK: - The fence drops only on a settled surface

    @Test func anUnsettledLandingKeepsTheFenceUpUntilTheSurfaceSettles() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        let landing = fence.flightLanded(surfaceSettled: false)
        #expect(landing == .awaitSettle)
        #expect(fence.phase == .settling)
        #expect(fence.isUp, "the latch is down but the page still shows the old note")

        // Still fenced while settling: a key typed now is refused.
        let refused = fence.refusesPolicedEdit()
        #expect(refused)

        let owed = fence.surfaceSettled()
        #expect(owed, "settling ⇒ a drain is owed")
        #expect(fence.isUp, "the fence stays up until the drain actually runs")
        let speak = fence.drain()
        #expect(speak)
        #expect(!fence.isUp)
    }

    @Test func aSettleReportWithNothingToWaitForOwesNoDrain() {
        var fence = StructuralFlightFence()
        let open = fence.surfaceSettled()
        #expect(open == false)
        fence.flightBegan()
        let flying = fence.surfaceSettled()
        #expect(flying == false, "flying is not settling — the door is still at work")
    }

    @Test func aFlightThatBeginsWhileTheLastIsSettlingTakesItOver() {
        var fence = StructuralFlightFence()
        fence.flightBegan()
        _ = fence.flightLanded(surfaceSettled: false)
        fence.flightBegan()
        #expect(fence.phase == .flying)
        let landing = fence.flightLanded(surfaceSettled: true)
        #expect(landing == .drain)
        _ = fence.drain()
        #expect(!fence.isUp)
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
