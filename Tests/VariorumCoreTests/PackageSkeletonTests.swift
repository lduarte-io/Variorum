import Testing
@testable import VariorumCore

@Test func packageSkeletonLinksAndSQLiteOpens() throws {
    let version = try VariorumCore.sqliteVersion()
    #expect(!version.isEmpty)
}
