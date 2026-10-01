import Dependencies
import Foundation
import GRDB

// Locks: reversible guards, fully orthogonal to commits (I6) — with the one
// spec'd consequence, not equivalence: sealing a post auto-commits its dirty
// buffers first.
extension Operations {
    /// Freeze a variant's buffer: to edit, branch or unlock. A dirty buffer
    /// is insured with one quiet auto commit first (author decision
    /// 2026-07-05, mirroring lockPost) — so unlock-then-edit can never
    /// destroy the exact text the lock was protecting, and idleAutoCommit
    /// stays correct in skipping locked variants.
    public func lockVariant(_ id: String) throws {
        try setVariantLock(id, locked: true)
    }

    public func unlockVariant(_ id: String) throws {
        try setVariantLock(id, locked: false)
    }

    /// The post-level seal ("complete"): auto-commits dirty live buffers
    /// (kind='auto'), then freezes — no edits, no new commits, pointer order
    /// and chosen variants frozen. The freeze itself is enforced as refusals
    /// in every other operation via the centralized locked-post guard.
    public func lockPost(_ id: String) throws {
        try database.write { db in
            try sealPost(db, id: id, now: date.now)
        }
    }

    /// Reversible, zero commits: unlocking restores exactly the pre-lock
    /// editing surface.
    public func unlockPost(_ id: String) throws {
        try database.write { db in
            try unsealPost(db, id: id, now: date.now)
        }
    }

    /// The `lockPost` body — shared with `sealReading` (13i-c U2), which seals
    /// every member on the BOOK's exact stamp (`now`): dirty live buffers are
    /// insured by one quiet auto commit each (the standing seal insurance),
    /// then the freeze. An already-sealed note is untouched — its own stamp
    /// stands (so it is "independent" of any book's unseal).
    func sealPost(_ db: Database, id: String, now: Date) throws {
        var post = try livePost(db, id)
        guard !post.locked else { return }
        _ = try autoCommitDirtyVariants(db, containerID: id, now: now)
        post.locked = true
        post.lockedAt = now
        post.updatedAt = now
        try post.update(db)
    }

    /// The `unlockPost` body — shared with `unsealReading` (13i-c U2).
    func unsealPost(_ db: Database, id: String, now: Date) throws {
        var post = try livePost(db, id)
        guard post.locked else { return }
        post.locked = false
        post.lockedAt = nil
        post.updatedAt = now
        try post.update(db)
    }

    private func setVariantLock(_ id: String, locked: Bool) throws {
        try database.write { db in
            var variant = try liveVariant(db, id)
            guard variant.locked != locked else { return }
            // The post seal refuses everything under the post (author-
            // ratified 2026-07-05) — including lock toggles, which would
            // otherwise let a dirty variant's insurance commit slip into a
            // sealed post.
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            let now = date.now
            if locked, try isDirty(db, variant) {
                _ = try insertCommit(db, variant: variant, kind: .auto, message: nil, now: now)
            }
            variant.locked = locked
            variant.updatedAt = now
            try variant.update(db)
        }
    }
}
