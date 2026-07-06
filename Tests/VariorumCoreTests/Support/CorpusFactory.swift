import Dependencies
import Foundation
import GRDB
@testable import VariorumCore

/// A seeded, deterministic corpus built entirely through Operations — which
/// makes every build a scale smoke test of the operations layer as well as
/// the benchmark bed. Two sizes of the same shape let the P1 benchmarks
/// assert ratios: the fixed-size probes (the 50-block big post, the 50-post
/// book, the tag tree) are identical in both corpora, only the surrounding
/// corpus grows.
enum CorpusFactory {
    struct Corpus {
        let db: AppDatabase
        /// The render probe: always 50 blocks, whatever the corpus size.
        let bigPostID: String
        /// A variant inside the big post (autosave benchmark).
        let bigPostVariantID: String
        /// The contrast probe: always 5 blocks.
        let smallPostID: String
        let smallPostVariantID: String
        /// Curated reading over 50 posts, both sizes.
        let bookReadingID: String
        /// Root of the fixed 6-tag tree.
        let tagRootID: String
        let blockCount: Int
    }

    /// Builds `posts × blocksPerPost` corpus blocks plus the fixed probes.
    /// Deterministic: incrementing UUIDs, a ticking clock, seeded jitter.
    static func build(posts: Int, blocksPerPost: Int, seed: UInt64 = 7) throws -> Corpus {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: {
            let ops = Operations()

            // The fixed probes first, so their row neighborhoods are
            // identical in both corpora.
            let tagRoot = try ops.createTag(name: "corpus")
            var childTags: [Tag] = []
            for i in 0..<5 {
                childTags.append(try ops.createTag(parent: tagRoot.id, name: "section\(i)"))
            }

            let bigPost = try ops.createPost(title: "big probe post")
            var bigVariantID = ""
            for b in 0..<50 {
                let minted = try ops.newBlock(in: bigPost.id, text: blockText(post: -1, block: b))
                if b == 0 { bigVariantID = minted.variant.id }
            }
            let smallPost = try ops.createPost(title: "small probe post")
            var smallVariantID = ""
            for b in 0..<5 {
                let minted = try ops.newBlock(in: smallPost.id, text: blockText(post: -2, block: b))
                if b == 0 { smallVariantID = minted.variant.id }
            }

            let book = try ops.createReading(name: "the book", kind: .curated)

            // The corpus body: journal-shaped posts with entry dates, some
            // fans, some lineage, some tags.
            var bookMembers = 0
            for p in 0..<posts {
                let month = (p / 28) % 12 + 1
                let day = p % 28 + 1
                let post = try ops.createPost(
                    title: "post \(p)",
                    profile: .journal,
                    entryDate: String(format: "2026-%02d-%02d", month, day))
                var firstBlock: Operations.NewBlockResult?
                for b in 0..<blocksPerPost {
                    let minted = try ops.newBlock(in: post.id, text: blockText(post: p, block: b))
                    if b == 0 { firstBlock = minted }
                }
                if bookMembers < 50 {
                    try ops.addPostToReading(post.id, to: book.id)
                    bookMembers += 1
                }
                if p % 10 == 0 {
                    try ops.applyTag(childTags[(p / 10) % childTags.count].id, toPost: post.id)
                }
                if p % 20 == 5, let first = firstBlock {
                    _ = try ops.branchVariant(first.block.id, from: first.variant.id)
                }
                if p % 25 == 7, let first = firstBlock {
                    // "Sentence one lives here."  cut after it (offset 24).
                    _ = try ops.divide(first.block.id, cut: 24)
                }
            }
            return Corpus(
                db: db,
                bigPostID: bigPost.id, bigPostVariantID: bigVariantID,
                smallPostID: smallPost.id, smallPostVariantID: smallVariantID,
                bookReadingID: book.id, tagRootID: tagRoot.id,
                blockCount: posts * blocksPerPost)
        }
    }

    /// ~120 chars, two sentences, ASCII — every block the same shape so
    /// only *counts* differ between corpora.
    static func blockText(post: Int, block: Int) -> String {
        "Sentence one lives here. Sentence two of block \(block) in post \(post) "
            + "carries on for a while so the buffer resembles real prose."
    }

    /// Operations over an existing corpus (the autosave benchmark): same
    /// deterministic world, no new IDs minted by the benchmark path.
    static func withOperations<T>(
        on corpus: Corpus, _ body: (Operations) throws -> T
    ) throws -> T {
        let tick = LockIsolated(0)
        return try withDependencies {
            $0.database = corpus.db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return Date(timeIntervalSince1970: 1_785_000_000).addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 99))
        } operation: {
            try body(Operations())
        }
    }
}
