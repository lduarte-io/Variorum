//
//  MobileEdgeGroundsBoardTests.swift
//  VariorumMobileTests
//
//  VM-47 (the walk's W-A1, redone) — **WHICH PAGE COLOURS THE STRIPS.** The
//  shell paints the strips beyond its band in the showing page's declared
//  edge grounds (`MobileEdgeGrounds.swift`); the board decides which
//  declaration that is. The rule, transition by transition: a stack's root
//  while the stack stands at its root; else its newest pushed screen, the
//  root's until a pushed screen has declared; never another band page's; a
//  withdrawn screen hands the strips back to the one below; a revision changes
//  a page's grounds in place without reordering. The rendered pins
//  (`MobileScreenEdgeGroundsTests`) hold the painting; these hold the rule.
//

import SwiftUI
import Testing
@testable import VariorumMobile

@MainActor
@Suite("Which page colours the strips beyond the band (VM-47, W-A1 redone)")
struct MobileEdgeGroundsBoardTests {
    private let room = MobileEdgeGrounds(top: .gray, bottom: .gray)
    private let paper = MobileEdgeGrounds(top: .white, bottom: .white)
    private let note = MobileEdgeGrounds(top: .yellow, bottom: .yellow)
    private let read = MobileEdgeGrounds(top: .brown, bottom: .brown)

    @Test func nothingDeclaredIsNothingShown() {
        let board = MobileEdgeGroundsBoard()
        #expect(board.grounds(of: .shelf, atRoot: true) == nil)
        #expect(board.grounds(of: .shelf, atRoot: false) == nil)
    }

    @Test func theRootStandsWhileItsStackIsAtItsRoot() {
        let board = MobileEdgeGroundsBoard()
        _ = board.declare(room, stack: .shelf, atRoot: true)
        // A pushed screen still mounted while the path has emptied (a pop's
        // slide) never wins over the root at the root.
        _ = board.declare(paper, stack: .shelf, atRoot: false)
        #expect(board.grounds(of: .shelf, atRoot: true) == room)
    }

    @Test func offTheRootTheNewestPushedScreenWins() {
        let board = MobileEdgeGroundsBoard()
        _ = board.declare(room, stack: .shelf, atRoot: true)
        _ = board.declare(note, stack: .shelf, atRoot: false)
        _ = board.declare(paper, stack: .shelf, atRoot: false)
        #expect(board.grounds(of: .shelf, atRoot: false) == paper)
    }

    @Test func untilAPushedScreenDeclaresTheRootStillStands() {
        let board = MobileEdgeGroundsBoard()
        _ = board.declare(room, stack: .library, atRoot: true)
        // The path is no longer empty, the arriving screen not yet appeared.
        #expect(board.grounds(of: .library, atRoot: false) == room)
    }

    @Test func aWithdrawnScreenHandsTheStripsBackToTheOneBelow() {
        let board = MobileEdgeGroundsBoard()
        _ = board.declare(room, stack: .shelf, atRoot: true)
        _ = board.declare(note, stack: .shelf, atRoot: false)
        let versions = board.declare(paper, stack: .shelf, atRoot: false)
        board.withdraw(versions)
        #expect(board.grounds(of: .shelf, atRoot: false) == note)
    }

    @Test func aBandNeighbourNeverColoursTheStrips() {
        let board = MobileEdgeGroundsBoard()
        _ = board.declare(room, stack: .shelf, atRoot: true)
        _ = board.declare(read, stack: .library, atRoot: false)
        #expect(board.grounds(of: .shelf, atRoot: true) == room)
        #expect(board.grounds(of: .shelf, atRoot: false) == room)
        #expect(board.grounds(of: .starred, atRoot: true) == nil)
    }

    @Test func aRevisionChangesTheGroundsInPlaceAndKeepsTheOrder() {
        let board = MobileEdgeGroundsBoard()
        _ = board.declare(room, stack: .shelf, atRoot: true)
        let listing = board.declare(paper, stack: .shelf, atRoot: false)
        let above = board.declare(note, stack: .shelf, atRoot: false)
        board.revise(listing, to: read)
        #expect(board.grounds(of: .shelf, atRoot: false) == note, "a revision below never jumps the queue")
        board.withdraw(above)
        #expect(board.grounds(of: .shelf, atRoot: false) == read)
    }
}
