// swift-tools-version: 6.2
// Single dev machine (M3, Xcode 26) as of 2026-07-06; no older-OS support — see CLAUDE.md environment notes.
import PackageDescription

let package = Package(
    name: "VariorumCore",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
    ],
    products: [
        .library(name: "VariorumCore", targets: ["VariorumCore"]),
        // 13n-b (A-1): the MCP door's server — linked ONLY by the Mac app
        // target; the iOS app never carries the SDK.
        .library(name: "VariorumMCP", targets: ["VariorumMCP"]),
    ],
    dependencies: [
        // Phase 13p (R13p-11, author-approved): the author's GRDB fork with the
        // README-documented SQLCipher recipe applied — pinned to the TAG
        // `v7.11.1+sqlcipher.1` (ladder R1-n5: a branch pin moves under
        // `swift package update`; the tag is immovable and sits at the same
        // revision 404dde041 the branch resolved, cut from the v7.11.1
        // release tag — the exact version the old `from: "7.0.0"` line had
        // resolved all along). Pulls Zetetic's official prebuilt
        // SQLCipher.swift (4.18.0 community). Deliberately NO
        // `SQLITE_HAS_CODEC` here: the flag gates GRDB's own compilation (the
        // fork sets it); a consuming target needs it only if its own source
        // says `#if SQLITE_HAS_CODEC`, and ours keys with a SQL pragma
        // (spike memo Correction #2 — an unused define invites false dependence).
        .package(url: "https://github.com/lduarte-io/GRDB.swift.git", exact: "7.11.1+sqlcipher.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.9.0"),
        // 13n-b (R-13n-2, her approval at the 13n sitting): the official MCP
        // Swift SDK — the app's second third-party dependency after GRDB.
        // Pinned EXACT: the SDK is 0.x and churns (the ruling's own words);
        // `swift package update` must never move it. Its `MCP` library links
        // swift-system, swift-log and mattt/eventsource; swift-nio and
        // swift-docc-plugin are fetched for the SDK's own conformance tools
        // and docs, never linked (the 13n-b plan's U1 record). Licence
        // notices ride Settings ▸ Acknowledgments (`AcknowledgmentsCopy`).
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", exact: "0.12.1"),
    ],
    targets: [
        // Vendored PHC Argon2 reference implementation (Phase 14b, R-7) —
        // pinned upstream commit + file-set rationale in Vendor/CArgon2/README.md.
        // ARGON2_NO_THREADS: single-threaded fill, no pthreads, thread.c not vendored.
        .target(
            name: "CArgon2",
            path: "Vendor/CArgon2",
            sources: ["src"],
            publicHeadersPath: "include",
            cSettings: [
                .define("ARGON2_NO_THREADS"),
                .headerSearchPath("src"),
                .headerSearchPath("include"),
            ]
        ),
        .target(
            name: "VariorumCore",
            dependencies: [
                "CArgon2",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            resources: [
                // BIP-39 English wordlist (Phase 14b, R-5) — provenance pin
                // in Vendor/BIP39/README.md.
                .copy("Resources/bip39-english.txt")
            ]
        ),
        // Phase 14b (L10): the headless wipe-and-repush executor — the
        // resyncReinitialize door, NEVER linked into any app (the apps link
        // VariorumCore; this CLI shell exists only for the architect's gate
        // act). Its brain is Crypto/VaultBootstrap.swift, tested in
        // VariorumCoreTests.
        .executableTarget(
            name: "vault-bootstrap",
            dependencies: ["VariorumCore"],
            path: "Tools/VaultBootstrap"
        ),
        // BRANCH-ONLY (`tools/strings-workbook`, never merges — issue #7's
        // branch rule; issue #5): the App Strings workbook generator. The
        // parser, the tier plan and the ops-driven mint live in ONE library
        // so the tests cover the real logic; the executable is the headless
        // road onto her store (the lobby's own passphrase road). Never linked
        // into any app. Record: notes/plans/strings-workbook-record.md.
        .target(
            name: "StringsWorkbook",
            dependencies: [
                "VariorumCore",
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            path: "Tools/StringsWorkbook/Sources"
        ),
        .executableTarget(
            name: "strings-workbook-mint",
            dependencies: ["StringsWorkbook", "VariorumCore"],
            path: "Tools/StringsWorkbook/CLI"
        ),
        .testTarget(
            name: "StringsWorkbookTests",
            dependencies: [
                "StringsWorkbook", "VariorumCore",
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            path: "Tools/StringsWorkbook/Tests"
        ),
        // 13n-b (A-1): THE MCP DOOR's server — transport · session · grant
        // authority · tool projections (P-9: never one god server object).
        // The grants substrate itself (tables, operations, the pure grant
        // rule) lives in VariorumCore, headless and SDK-free; this target is
        // the wire.
        .target(
            name: "VariorumMCP",
            dependencies: [
                "VariorumCore",
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(
            name: "VariorumMCPTests",
            dependencies: [
                "VariorumMCP", "VariorumCore",
                .product(name: "MCP", package: "swift-sdk"),
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .testTarget(
            name: "VariorumCoreTests",
            // CArgon2 direct: the RFC 9106 full-context vector calls
            // argon2_ctx (secret + ad), which PassphraseKDF deliberately
            // does not expose.
            dependencies: ["VariorumCore", "CArgon2"]
        ),
    ]
)
