//
//  SystemClockLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `ClockLeaf` (`Executor/Leaves.swift`): the wall clock. Its dates are display
//  and record data only (SyncSpec §9: no clock trust — ordering authority is never a timestamp).
//

import Foundation
import VariorumCore

nonisolated final class SystemClockLeaf: ClockLeaf, @unchecked Sendable {
    func now() -> Date { Date() }
}
