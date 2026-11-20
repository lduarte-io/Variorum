//
//  TimingStats.swift
//  VariorumCore
//
//  VM-65 (the VM-64 run, batch 1) — THE TIMING LAYER'S STATISTICS: what one
//  series keeps. The record is `notes/plans/fixes/vm-64-timing-and-lags.md`.
//
//  A series is a list of numbers — a span's durations in milliseconds, or a
//  per-act count ("reads per open"). This keeps:
//
//  · a FIXED RING of the most recent `capacity` samples (bounded memory, the
//    phone's jetsam bar — MobileSoul §2), written in place once full;
//  · the ALL-TIME count and the last sample, which survive the ring's wrap;
//  · the median, minimum and maximum, computed at READ time over the ring
//    (never on the recording road — a sample costs one array write).
//
//  Numbers only. Nothing here can hold text.
//

import Foundation

public struct TimingStats: Sendable {
    /// The ring's size unless a recorder says otherwise. 64 runs of one act is
    /// more than a sitting's worth; the median is "of the last 64" past that.
    public static let defaultCapacity = 64

    public let capacity: Int
    /// Every sample ever recorded into this series (it outlives the ring).
    public private(set) var count = 0
    /// The most recent sample.
    public private(set) var last: Double?
    /// The ring. Until it fills, `ring.count < capacity` and samples are
    /// appended; after, `next` is the slot the next sample overwrites (the
    /// oldest one).
    private var ring: [Double] = []
    private var next = 0

    public init(capacity: Int = TimingStats.defaultCapacity) {
        precondition(capacity > 0, "a timing ring needs at least one slot")
        self.capacity = capacity
    }

    /// O(1): one array write (an append until the ring is full).
    public mutating func record(_ value: Double) {
        count += 1
        last = value
        if ring.count < capacity {
            if ring.isEmpty { ring.reserveCapacity(capacity) }
            ring.append(value)
        } else {
            ring[next] = value
        }
        next = (next + 1) % capacity
    }

    /// The samples the ring still holds, OLDEST first. At most `capacity`.
    public var retained: [Double] {
        guard ring.count == capacity, next != 0 else { return ring }
        return Array(ring[next...]) + Array(ring[..<next])
    }

    /// How many samples the statistics below are computed over.
    public var retainedCount: Int { ring.count }

    /// The median of the retained samples (the mean of the middle two when
    /// their number is even). nil before the first sample.
    public var median: Double? {
        guard !ring.isEmpty else { return nil }
        let sorted = ring.sorted()
        let mid = sorted.count / 2
        if sorted.count % 2 == 1 { return sorted[mid] }
        return (sorted[mid - 1] + sorted[mid]) / 2
    }

    /// The smallest retained sample.
    public var minimum: Double? { ring.min() }
    /// The largest retained sample.
    public var maximum: Double? { ring.max() }

    /// A restore's one adjustment (`TimingRecorder.restore`): a series re-ringed
    /// from a persisted record keeps the all-time count and the last sample it
    /// was persisted with. The count is never below what the ring holds.
    mutating func adoptCount(_ total: Int, last persisted: Double?) {
        count = max(total, ring.count)
        if let persisted { last = persisted }
    }
}

// MARK: - Equality (what the series holds, never where the ring's cursor sits)

extension TimingStats: Equatable {
    /// Two series are equal when they hold the same samples in the same order
    /// with the same totals — a ring rebuilt from a persisted record starts its
    /// cursor at zero, and that is not a difference.
    public static func == (lhs: TimingStats, rhs: TimingStats) -> Bool {
        lhs.capacity == rhs.capacity && lhs.count == rhs.count && lhs.last == rhs.last
            && lhs.retained == rhs.retained
    }
}

// MARK: - Codable (the persisted shape — numbers only)

extension TimingStats: Codable {
    private enum CodingKeys: String, CodingKey {
        case capacity, count, last, samples
    }

    /// The samples are written oldest first, so a decoded series rebuilds an
    /// ordinary ring in the same order (`next` follows from the count).
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(capacity, forKey: .capacity)
        try c.encode(count, forKey: .count)
        try c.encodeIfPresent(last, forKey: .last)
        try c.encode(retained, forKey: .samples)
    }

    /// A decoded record is held to the ring's own invariants rather than
    /// trusted: a capacity outside `1…defaultCapacity` takes the default (the
    /// ring's own bound — a capacity above it, read as written, kept every
    /// sample the file held and reserved that many slots at the first sample;
    /// VM-64 ladder round 3, finding 5(b)), extra samples keep only the newest
    /// `capacity`, and the count is never below what is held.
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let stored = try c.decode(Int.self, forKey: .capacity)
        self.init(capacity: (1...TimingStats.defaultCapacity).contains(stored)
            ? stored : TimingStats.defaultCapacity)
        let samples = try c.decode([Double].self, forKey: .samples)
        for value in samples.suffix(capacity) { record(value) }
        count = max(try c.decode(Int.self, forKey: .count), ring.count)
        last = try c.decodeIfPresent(Double.self, forKey: .last) ?? retained.last
    }
}
