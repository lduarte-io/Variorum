import Foundation
import GRDB

// **VX-840 (the VX-828 run, batch E) — THE WING'S UNUSED TAGS.** Her ask
// (2026-11-04): *"file a ticket to be able to delete every tag that's not on a
// note currently"*. Settings ▸ Tags lists them (checked) and deletes the
// checked ones in one confirmed act (`Operations.deleteUnusedTags`).
//
// "Unused" is vx-809's ONE brain, consumed exactly as the run record's
// signature paragraph gives it — never a twin:
//   unused(tag) = !Queries.tagSubtreeIsWorn(db, tagID: tag.id,
//                    scope: .library(countingTrashRevivable: true))
// — no live application (post or block) on a live wearer anywhere in the
// tag's subtree, AND none a restore would bring back (a wearer in the Trash
// keeps its tags in use: P-828-3, her lean, ruled at the batch's fork).
//
// WORN is subtree-honest (a tag whose child is worn is worn — `deleteTag`
// takes the subtree), so UNUSED is closed downward: every tag under an unused
// tag is unused too. The listing leans on that ONE fact to ask the brain once
// per maximal unused subtree rather than once per tag; the answer is the same
// set either way (`UnusedTagsTests` checks it tag by tag).
extension Queries {
    /// **The live tags of `wingID`'s vocabulary that nothing wears**, in path
    /// order (parents before children — the order Settings ▸ Tags lists in).
    /// The wing reads as surfaces read it (`allTags`' scope: Home also lists
    /// a dangling wing's). P1: ∝ the wing's tags (author-scale metadata), each
    /// question ∝ its subtree's applications.
    public static func unusedTags(_ db: Database, wingID: String) throws -> [Tag] {
        var unused: [Tag] = []
        // The subtrees found unused so far — by the STORED wing and the path
        // prefix, `tagSubtree`'s own rule (Home's listing also holds a
        // dangling wing's tags, which are another subtree's).
        var unusedRoots: [(wing: String, prefix: String)] = []
        for tag in try allTags(db, wingID: wingID) {
            if unusedRoots.contains(where: { $0.wing == tag.wingId && tag.path.hasPrefix($0.prefix) }) {
                unused.append(tag)  // under an unused tag — unused by the closure
                continue
            }
            guard try !tagSubtreeIsWorn(
                db, tagID: tag.id, scope: .library(countingTrashRevivable: true))
            else { continue }
            unused.append(tag)
            unusedRoots.append((tag.wingId, tag.path + "/"))
        }
        return unused
    }

    /// **The listing's held observation's region** — every table the read
    /// touches, NARROWED to the columns it reads on the two keystroke-rate
    /// tables: `container` and `block` are read only for `id` and
    /// `deleted_at` (a wearer's life), so an autosave's `last_touched_at` /
    /// churn stamps never wake the count (P1), while a trash, a restore, a
    /// purge or any application write does. `wing` likewise only for Home's
    /// dangling-wing scope. Pinned against the regions GRDB derives from every
    /// statement the read runs (`UnusedTagsTests`).
    public static func unusedTagRegions() -> [any DatabaseRegionConvertible] {
        [
            Table("tag"), Table("post_tag"), Table("block_tag"),
            Table("container").select(Column("id"), Column("deleted_at")),
            Table("block").select(Column("id"), Column("deleted_at")),
            Table("wing").select(Column("id"), Column("deleted_at")),
        ]
    }
}

extension AppDatabase {
    /// **The wing's unused tags, live** — Settings ▸ Tags' door count and its
    /// sheet's rows (VX-840). Woken by the NAMED region
    /// (`observe(tracking:)`), so its re-fetch runs on a READER after a
    /// commit, never on the writer inside one (VX-670's lesson, batch D's
    /// `observeEmptyTrashBlocks` precedent).
    public func observeUnusedTags(wingID: String) -> AsyncValueObservation<[Tag]> {
        observe(tracking: Queries.unusedTagRegions()) {
            try Queries.unusedTags($0, wingID: wingID)
        }
    }
}
