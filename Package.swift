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
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.9.0"),
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
        .testTarget(
            name: "VariorumCoreTests",
            // CArgon2 direct: the RFC 9106 full-context vector calls
            // argon2_ctx (secret + ad), which PassphraseKDF deliberately
            // does not expose.
            dependencies: ["VariorumCore", "CArgon2"]
        ),
    ]
)
