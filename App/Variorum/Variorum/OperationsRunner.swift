//
//  OperationsRunner.swift
//  Variorum
//
//  Serial, off-main executor for operations-layer writes.
//
//  - P2: DB I/O never runs on the main thread — `run` hops to this actor's
//    executor (the cooperative pool), and GRDB's own queues do the I/O.
//  - Serialization: bodies are synchronous, so two `run` calls can never
//    interleave — this is the guard structural undo requires (KnownIssues
//    "structural-undo UI wiring": two concurrent `undo()` calls must execute
//    one at a time).
//

import VariorumCore

actor OperationsRunner {
    private let operations: Operations

    init(operations: Operations) {
        self.operations = operations
    }

    /// Runs one operations-layer body serially, off the main thread.
    /// The body is synchronous by design: no suspension point can interleave
    /// two bodies.
    @discardableResult
    func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) throws -> T {
        try body(operations)
    }
}
