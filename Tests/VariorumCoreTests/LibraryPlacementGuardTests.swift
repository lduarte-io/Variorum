import Foundation
import Testing

@testable import VariorumCore

// Phase 13x U2 row 9 — the placement guard's two pure rules, pinned.

@Suite("13x U2 — the iCloud-Drive / live-library placement guard")
struct LibraryPlacementGuardTests {
    @Test func theICloudDriveHomeAndAppContainersReadAsInside() {
        #expect(LibraryPlacementGuard.isInsideICloudDrive(URL(fileURLWithPath:
            "/Users/l/Library/Mobile Documents/com~apple~CloudDocs/Writing")))
        #expect(LibraryPlacementGuard.isInsideICloudDrive(URL(fileURLWithPath:
            "/Users/l/Library/Mobile Documents/iCloud~com~example~app/Documents")))
        // The marker is a path COMPONENT, not a substring.
        #expect(!LibraryPlacementGuard.isInsideICloudDrive(URL(fileURLWithPath:
            "/Users/l/Documents/Mobile Documents backup notes")))
        #expect(!LibraryPlacementGuard.isInsideICloudDrive(URL(fileURLWithPath:
            "/Users/l/Documents/Writing")))
    }

    @Test func theLiveLibrarysOwnFolderAndItsAncestorsAreRefusedAsDestinations() {
        let store = URL(fileURLWithPath:
            "/Users/l/Library/Application Support/Variorum/variorum.sqlite")
        // The store's folder, the store file itself, and a containing
        // ancestor all point the picker at the library.
        #expect(LibraryPlacementGuard.isLiveLibraryFolder(
            URL(fileURLWithPath: "/Users/l/Library/Application Support/Variorum"), storeURL: store))
        #expect(LibraryPlacementGuard.isLiveLibraryFolder(store, storeURL: store))
        #expect(LibraryPlacementGuard.isLiveLibraryFolder(
            URL(fileURLWithPath: "/Users/l/Library/Application Support"), storeURL: store))
        // A sibling folder, a folder INSIDE the library folder, and an
        // unrelated home are all legal.
        #expect(!LibraryPlacementGuard.isLiveLibraryFolder(
            URL(fileURLWithPath: "/Users/l/Library/Application Support/Variorum-dev"),
            storeURL: store))
        #expect(!LibraryPlacementGuard.isLiveLibraryFolder(
            URL(fileURLWithPath: "/Volumes/Backup/Variorum"), storeURL: store))
    }
}
