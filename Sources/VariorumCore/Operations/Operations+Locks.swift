import Dependencies
import Foundation
import GRDB

// Locks: reversible guards, fully orthogonal to commits (I6) — with the one
// spec'd consequence, not equivalence: sealing a post auto-commits its dirty
// buffers first.
extension Operations {
    /// Freeze a variant's buffer: to edit, branch or unlock.
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
            var post = try livePost(db, id)
            guard !post.locked else { return }
            let now = date.now
            _ = try autoCommitDirtyVariants(db, containerID: id, now: now)
            post.locked = true
            post.lockedAt = now
            post.updatedAt = now
            try post.update(db)
        }
    }

    /// Reversible, zero commits: unlocking restores exactly the pre-lock
    /// editing surface.
    public func unlockPost(_ id: String) throws {
        try database.write { db in
            var post = try livePost(db, id)
            guard post.locked else { return }
            post.locked = false
            post.lockedAt = nil
            post.updatedAt = date.now
            try post.update(db)
        }
    }

    private func setVariantLock(_ id: String, locked: Bool) throws {
        try database.write { db in
            var variant = try liveVariant(db, id)
            guard variant.locked != locked else { return }
            variant.locked = locked
            variant.updatedAt = date.now
            try variant.update(db)
        }
    }
}
