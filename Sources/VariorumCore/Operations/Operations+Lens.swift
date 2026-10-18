import Dependencies
import Foundation
import GRDB

// Saved lenses (Phase 11, Step A1 — v1_7; the kickoff spike's confirmed
// design). A lens is a durable named selection profile over ONE post:
// SPARSE overrides over chosen (only divergences stored; un-overridden
// slots follow the post's chosen; the empty lens is the transparent
// new-thread default). A lens is NEVER rendering truth — nothing here
// touches `chosen_variant_id` (I3); `adoptLens` (Step A2) is the one
// compound door, and it is a chain of ordinary `chooseVariant`s.
//
// SEAL POSTURE (PROVISIONAL, Phase 11 — the QUESTIONS bundle with canvas
// and block-name): lens CRUD is ALLOWED under a sealed post. A lens is "a
// saved way of LOOKING"; the seal freezes authoring (edits, commits,
// pointer order, chosen variants, fan growth — all still refused by their
// own ops), and the 9d "Show Takes" ratification already establishes that
// viewing a sealed post's takes is not authoring. The conservative
// alternative (refuse everything under the post) is recorded for the
// author. Note the composition stays safe: adoptLens writes chosen and
// REFUSES under seal; diverge-here mints takes (fan growth) and refuses.
extension Operations {
    // MARK: - CRUD

    /// Mints a lens on a post. Names must be non-blank; duplicates are
    /// legal (no uniqueness — deliberately no sync-repair class).
    @discardableResult
    public func createLens(post postID: String, name: String) throws -> Lens {
        try database.write { db in
            _ = try livePost(db, postID)
            // VX-357: U+0000 removed first (`StoredText`), then the trim.
            let trimmed = StoredText.stripped(name).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                throw OperationError.invalidLensName(name: name)
            }
            let now = date.now
            let lens = Lens(
                id: newID(), ownerId: currentOwnerID(), containerId: postID,
                name: trimmed, createdAt: now, updatedAt: now)
            try lens.insert(db)
            return lens
        }
    }

    public func renameLens(_ lensID: String, newName: String) throws {
        try database.write { db in
            var lens = try liveLens(db, lensID)
            let trimmed = StoredText.stripped(newName).trimmingCharacters(in: .whitespacesAndNewlines)  // VX-357
            guard !trimmed.isEmpty else {
                throw OperationError.invalidLensName(name: newName)
            }
            guard lens.name != trimmed else { return }
            lens.name = trimmed
            lens.updatedAt = date.now
            try lens.update(db)
        }
    }

    /// "Duplicate lens" — riff on a thread without touching it (the spike's
    /// recorded gesture). Mints a fresh lens on the same post and copies
    /// the LIVE choices as fresh rows. Default name = "<name> copy"
    /// (build-time call, recorded in the closeout).
    @discardableResult
    public func duplicateLens(_ lensID: String, name: String? = nil) throws -> Lens {
        try database.write { db in
            let source = try liveLens(db, lensID)
            let trimmed = StoredText.stripped(name)?.trimmingCharacters(in: .whitespacesAndNewlines)  // VX-357
            let copyName = (trimmed?.isEmpty ?? true) ? source.name + " copy" : trimmed!
            let now = date.now
            let copy = Lens(
                id: newID(), ownerId: currentOwnerID(), containerId: source.containerId,
                name: copyName, createdAt: now, updatedAt: now)
            try copy.insert(db)
            let choices = try LensChoice
                .filter(Column("lens_id") == lensID && Column("deleted_at") == nil)
                .order(Column("id"))
                .fetchAll(db)
            for choice in choices {
                try LensChoice(
                    id: newID(), lensId: copy.id, blockId: choice.blockId,
                    variantId: choice.variantId, createdAt: now, updatedAt: now)
                    .insert(db)
            }
            return copy
        }
    }

    /// Tombstones the lens; its choices cascade by trigger. The post and
    /// its chosen pointers are untouched — deleting a way of looking never
    /// deletes what is looked at.
    public func deleteLens(_ lensID: String) throws {
        try database.write { db in
            var lens = try liveLens(db, lensID)
            let now = date.now
            lens.deletedAt = now
            lens.updatedAt = now
            try lens.update(db)
        }
    }

    // MARK: - Choices (sparse overrides)

    /// Sets the lens's pick for one block — upsert on the live (lens,
    /// block) row (metadata CAS). Guards mirror `chooseVariant` exactly:
    /// the variant must be live, ACTIVE, and belong to the block; the
    /// block must be live-placed in the lens's post.
    @discardableResult
    public func setLensChoice(
        lens lensID: String, block blockID: String, variant variantID: String
    ) throws -> LensChoice {
        try database.write { db in
            let lens = try liveLens(db, lensID)
            _ = try liveBlock(db, blockID)
            guard let placement = try livePlacement(db, blockID: blockID),
                  placement.containerId == lens.containerId
            else {
                throw OperationError.blockNotInContainer(
                    blockID: blockID, containerID: lens.containerId)
            }
            let variant = try liveVariant(db, variantID)
            guard variant.blockId == blockID else {
                throw OperationError.variantNotFound(id: variantID)
            }
            guard variant.status == .active else {
                throw OperationError.archivedVariant(id: variantID)
            }
            let now = date.now
            if var existing = try liveChoice(db, lensID: lensID, blockID: blockID) {
                existing.variantId = variantID
                existing.updatedAt = now
                try existing.update(db)
                return existing
            }
            let choice = LensChoice(
                id: newID(), lensId: lensID, blockId: blockID,
                variantId: variantID, createdAt: now, updatedAt: now)
            try choice.insert(db)
            return choice
        }
    }

    /// Removes the override — the slot follows the post's chosen again
    /// (sparseness restored, not "chosen copied in").
    public func clearLensChoice(lens lensID: String, block blockID: String) throws {
        try database.write { db in
            _ = try liveLens(db, lensID)
            guard var choice = try liveChoice(db, lensID: lensID, blockID: blockID) else {
                throw OperationError.lensChoiceNotFound(lensID: lensID, blockID: blockID)
            }
            let now = date.now
            choice.deletedAt = now
            choice.updatedAt = now
            try choice.update(db)
        }
    }

    // MARK: - Internals

    func liveLens(_ db: Database, _ id: String) throws -> Lens {
        guard let lens = try Lens.fetchOne(db, key: id), lens.deletedAt == nil else {
            throw OperationError.lensNotFound(id: id)
        }
        return lens
    }

    private func liveChoice(
        _ db: Database, lensID: String, blockID: String
    ) throws -> LensChoice? {
        try LensChoice
            .filter(Column("lens_id") == lensID
                    && Column("block_id") == blockID
                    && Column("deleted_at") == nil)
            .fetchOne(db)
    }
}
