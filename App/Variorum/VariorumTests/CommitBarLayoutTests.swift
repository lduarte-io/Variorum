//
//  CommitBarLayoutTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 1, item 6 — **the bottom bar spreads back out.**
//  Her ruling: *"this bottom bar should be spread out again, unless the
//  window is small and it needs to be collapsed."* The shipped switch
//  collapsed below 1080 pt — an ORDINARY editor pane, which is exactly the
//  cramped two-row state her screenshot showed. The decision is a pure
//  function now, and this pin holds the ruled behaviour:
//  **red on old** — at 900 pt (an ordinary window's editor pane) the old
//  bar used two rows.
//

import Foundation
import Testing
@testable import Variorum

@Suite("The bottom bar's one-row/two-row switch (Act 10 item 6)")
struct CommitBarLayoutTests {
    @Test func ordinaryWidthsKeepOneRow() {
        // RED ON OLD: 900 < the shipped 1080 collapsed an ordinary pane.
        #expect(!CommitBar.usesTwoRows(width: 900))
        #expect(!CommitBar.usesTwoRows(width: 1000))
        #expect(!CommitBar.usesTwoRows(width: 1400))
    }

    @Test func genuinelySmallWidthsStillCollapse() {
        // The book-inline form and a narrow split pane — the fallback her
        // ruling keeps.
        #expect(CommitBar.usesTwoRows(width: 500))
        #expect(CommitBar.usesTwoRows(width: 700))
    }

    @Test func anUnmeasuredBarNeverCollapses() {
        // Width 0 = the first pass before geometry lands: one row, so the
        // bar does not flash two rows while mounting.
        #expect(!CommitBar.usesTwoRows(width: 0))
    }
}
