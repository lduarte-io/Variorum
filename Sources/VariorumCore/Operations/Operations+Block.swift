import Dependencies
import Foundation
import GRDB

extension Operations {
    /// Everything `newBlock` mints, for callers and state-transition tests.
    public struct NewBlockResult: Equatable, Sendable {
        public let block: Block
        public let variant: Variant
        public let placement: ContainerBlock
    }

    /// AppSpec §9: INSERT block; INSERT variant(working_text=text); set
    /// block.default_variant_id; INSERT container_block(chosen=variant).
    /// The block↔variant FK circle resolves by inserting the block with a
    /// NULL default first, then pointing it at the freshly inserted variant.
    @discardableResult
    public func newBlock(
        in containerID: String, text: String, at insert: InsertPosition = .end
    ) throws -> NewBlockResult {
        try database.write { db in
            let container = try liveContainer(db, containerID)
            try ensureUnlocked(container)

            let minted = try mintBlock(db, text: text, in: containerID, at: insert, now: date.now)
            return NewBlockResult(
                block: minted.block, variant: minted.variant, placement: minted.placement)
        }
    }
}
