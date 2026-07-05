import Foundation

/// Typed refusals from the operations layer. Every guard an invariant or spec
/// rule requires surfaces as one of these — never a silent no-op, never a
/// SQLite error leaking domain meaning.
public enum OperationError: Error, Equatable, Sendable {
    // Missing or tombstoned targets.
    case containerNotFound(id: String)
    case containerNotDeleted(id: String)
    case blockNotFound(id: String)
    case variantNotFound(id: String)
    case commitNotFound(id: String)
    case readingNotFound(id: String)
    case tagNotFound(id: String)
    case referenceNotFound(id: String)

    // Wrong target shape.
    case wrongContainerKind(id: String, expected: ContainerKind)
    case wrongReadingKind(id: String, expected: ReadingKind)

    // Locks (reversible guards, I6).
    case lockedPost(id: String)
    case lockedVariant(id: String)
    case lockedReading(id: String)

    // Variant lifecycle.
    /// I10: removing a live block's last live active variant is deleting the
    /// block — the caller should call `deleteBlock` instead.
    case lastActiveVariant(id: String)
    /// The ops-layer live guard the schema's RESTRICT cannot provide under
    /// soft delete: a variant some live slot renders cannot be removed.
    case variantIsChosen(id: String)
    case archivedVariant(id: String)

    // Placement (I2).
    case blockAlreadyPlaced(id: String)
    case blockNotPlaced(id: String)
    case blockNotDeleted(id: String)

    // Reading membership.
    case postNotInReading(postID: String, readingID: String)
    case alreadyInReading(postID: String, readingID: String)
    case readingAtCapacity(id: String)

    // Structural operations (Phase 3).
    /// Extract's span is not a boundary-adjacent prefix/suffix of the
    /// rendered variant's text (a middle span is a divide), or it is blank,
    /// out of bounds, grapheme-splitting, or the whole text.
    case spanNotExtractable(blockID: String)
    /// A cut offset that is out of bounds, splits a grapheme cluster, or
    /// leaves an empty half after seam trimming.
    case invalidCut(variantID: String, cut: Int)
    /// Single-variant divide addressed a block with more than one live
    /// active variant — that is the multi-variant W ceremony (`divideW`).
    case fannedBlock(id: String)
    /// divideW needs at least one marked variant to carry the cut through.
    case noMarkedVariants(blockID: String)
    /// Merge requires its two blocks placed adjacently in one container.
    case blocksNotAdjacent(first: String, second: String)
    /// poolDragCopy's source must live in a pool.
    case blockNotInPool(id: String)

    // Tags.
    case duplicateTagPath(path: String)
    case invalidTagName(name: String)
    case alreadyTagged(tagID: String, targetID: String)
    case tagNotApplied(tagID: String, targetID: String)
}
