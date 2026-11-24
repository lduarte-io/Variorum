//
//  MobileLineStandingOfferTests.swift
//  VariorumMobileTests
//
//  **VM-55 ladder round 1, finding 2 (MINOR, confirmed) — a STANDING offer on
//  the phone is an ordinary offer.** `StatusCenter.stand` (VX-676) shows an
//  offer at the toast's prominence, then keeps it in `standing` for the Mac's
//  quiet line until its owner ends it. The phone has no quiet line and no ✕:
//  its one line draws `status.current` alone. So a standing offer said on the
//  phone would show for the seam's six seconds and then live on in state with
//  no surface and no road out — `spoken` would even report it as showing. On
//  the phone placement, a standing offer is therefore an ordinary offer until
//  a phone face for standing offers exists: it draws with its door, fades on
//  the seam's clock (P-55-3), and is never kept; ending it while it shows takes
//  it off the line at once.
//
//  Pure, over the seam's own API (the defect lives there, so the pin needs no
//  caller — the one `stand` caller today is the Mac's MCP door). The Mac's
//  road is untouched and guarded by its own suites (`VM61MacStatusSeamPinTests`
//  drives stand → clear → lineItem → endStanding on a Mac centre;
//  `StatusCenterTests`, `MCPShowOfferFacesTests`, `MCPTrailTests`).
//
//  **Red on old** (the tree before the fix): `standPutsAnOrdinaryOfferOnTheLine`
//  (its `standing == nil`) and `afterTheFadeNothingIsLeftWithoutASurface` (the
//  stranded offer survives the fade in `lineItem` and `spoken`).
//  `endingTheOfferWhileItShowsTakesItOffTheLine` is green on both trees — it
//  guards the new arm's ORDER (a phone arm placed after the Mac's `standing`
//  guard would be a silent no-op there).
//

import Foundation
import Testing
@testable import VariorumMobile

@MainActor
@Suite("VM-55 round 1, finding 2 — a standing offer on the phone is an ordinary offer", .serialized)
struct MobileLineStandingOfferTests {
    /// The phone's placement (the phone build's own default, stated), on a
    /// short clock.
    private func phoneCenter() -> StatusCenter {
        let status = StatusCenter()
        status.placement = .phoneLine
        status.dismissAfter = .milliseconds(30)
        return status
    }

    private func standOffer(_ status: StatusCenter, _ text: String) -> UUID? {
        status.stand(
            text, action: .init(label: "Open", perform: {}),
            dismiss: .init(label: "Dismiss", perform: {}))
    }

    /// Polls until the line is empty (the seam's clock runs on a Task).
    private func fade(_ status: StatusCenter) async -> Bool {
        for _ in 0..<400 where status.current != nil {
            try? await Task.sleep(for: .milliseconds(5))
        }
        return status.current == nil
    }

    /// (a) The offer is on the phone's line, as an offer, with its door — and
    /// nothing is kept standing behind it.
    @Test func standPutsAnOrdinaryOfferOnTheLine() throws {
        let status = phoneCenter()
        let id = try #require(standOffer(status, "Show me this?"))
        #expect(status.current?.id == id, "the line shows it")
        #expect(status.current?.kind == .offer)
        #expect(status.current?.action?.label == "Open", "with its door")
        #expect(status.standing == nil, "the phone keeps no standing offer")
    }

    /// (b) THE RED-ON-OLD HALF: after the seam's clock, nothing is left in
    /// state that no surface draws — the line, the (Mac's) quiet line and what
    /// the centre reports as showing are all empty.
    @Test func afterTheFadeNothingIsLeftWithoutASurface() async throws {
        let status = phoneCenter()
        _ = try #require(standOffer(status, "Show me this?"))
        #expect(await fade(status), "the offer fades on the seam's clock")
        #expect(status.current == nil)
        #expect(status.lineItem == nil, "no stranded offer behind the line")
        #expect(status.spoken == nil, "nothing reported as showing that is not on screen")
    }

    /// (c) Ending the offer while it shows (taken, or its client gone) takes
    /// it off the line at once — and only the offer named.
    @Test func endingTheOfferWhileItShowsTakesItOffTheLine() throws {
        let status = phoneCenter()
        let first = try #require(standOffer(status, "First?"))
        let second = try #require(standOffer(status, "Second?"))
        #expect(status.current?.id == second, "a newer offer replaces the older on the line")
        status.endStanding(first)
        #expect(status.current?.id == second, "the older one's road never ends the newer")
        status.endStanding(second)
        #expect(status.current == nil, "ended while it showed: off the line at once")
        #expect(status.spoken == nil)
    }
}
