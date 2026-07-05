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
