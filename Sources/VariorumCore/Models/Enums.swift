import GRDB

/// Column vocabularies, mirroring the CHECK constraints in AppSpec §7 exactly.
/// `DatabaseValueConvertible` so they can appear directly in query filters.

public enum ContainerKind: String, Codable, Sendable, DatabaseValueConvertible {
    case post, pool
}

/// `container.profile` — a UI profile, never a data-model difference
/// (CoreDescription §8). `reading.profile` is a different, un-CHECKed
/// vocabulary and stays a plain string.
public enum Profile: String, Codable, Sendable, DatabaseValueConvertible {
    case journal, blog, bookChapter = "book_chapter", generic, pool
}

public enum VariantStatus: String, Codable, Sendable, DatabaseValueConvertible {
    case active, archived
}

public enum EdgeType: String, Codable, Sendable, DatabaseValueConvertible {
    case derivedFrom = "derived_from"
    case versionOf = "version_of"
}

public enum CommitKind: String, Codable, Sendable, DatabaseValueConvertible {
    case manual, auto
}

public enum ReadingKind: String, Codable, Sendable, DatabaseValueConvertible {
    case curated, smart
}

public enum SortField: String, Codable, Sendable, DatabaseValueConvertible {
    case manual
    case entryDate = "entry_date"
    case createdAt = "created_at"
    case lastTouched = "last_touched"
    case lastMajorRevision = "last_major_revision"
}

public enum SortDirection: String, Codable, Sendable, DatabaseValueConvertible {
    case asc, desc
}

public enum Segmentation: String, Codable, Sendable, DatabaseValueConvertible {
    case oneBlock = "one_block"
    case paragraph, sentence
}

public enum ReferenceKind: String, Codable, Sendable, DatabaseValueConvertible {
    case file, url
}

/// The fan-out appearance (Phase 11 kickoff spike, record item 1 — ALL
/// FOUR ship as a user SETTING: "different styles of use that are super
/// defensible"). Stored in the synced `setting` table under 'fan_style'
/// (document semantics, like segmentation — the same fan opens the same
/// way on every device); whichever style is set is what expand-all-fans
/// opens document-wide. Default 'stack' (build-time call, recorded in the
/// Phase 11 closeout — the closest kin of the shipped FanPanel).
public enum FanStyle: String, Codable, Sendable, CaseIterable, DatabaseValueConvertible {
    case stack
    case carousel
    case marginGrid = "margin_grid"
    case slotSplit = "slot_split"
}
