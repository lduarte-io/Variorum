# Building Variorum

Everything on this page works from a fresh clone, with no Apple developer account, no signing identity, no Variorum account and no server.

## What you need

- A Mac with Xcode. Variorum is built and tested with Xcode 27.1 on macOS 27; the app runs on macOS 26 and later. Other Xcode versions are untested.
- Git, and the repository's full history (see below).
- Network access to github.com and download.swift.org. The first build fetches the Swift packages (each pinned to a version and a commit), a prebuilt copy of swift-syntax, and two prebuilt frameworks, SQLCipher and Sparkle (each pinned by checksum).

## Get the source

Clone the repository with its full history:

```sh
git clone https://github.com/lduarte-io/Variorum.git
cd Variorum
```

A shallow clone (`--depth`) or a ZIP download won't build the app. Its build number is the repository's commit count, and the build refuses to guess when the history isn't there. The core package below builds either way.

## The core package

From the repository's root:

```sh
swift build
swift test
```

This is the model, the database, the operations, sync's client side and the MCP server, with no Xcode project involved.

- Warnings that a dependency "is not used by any target" are expected. Those lines pin the version of every package in the graph, so a fresh resolution lands on exactly the committed set. `Tools/verify-pins` checks a resolved state against the committed lockfiles.
- A few of the MCP server's tests open real local sockets and are sensitive to timing on a busy machine. If one fails in a full run, run it again on its own, for example `swift test --filter MCPHarnessTimeLimitTests`.

## The Mac app

```sh
cd App/Variorum
xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO build
```

The project signs with my developer team, and the app's entitlements include a keychain access group, which needs a provisioning profile. Without one, even ad hoc signing stops with "requires a provisioning profile", so this builds the app with signing turned off. The result is `Build/Products/Debug/Variorum.app` in Xcode's DerivedData folder (or wherever `-derivedDataPath` points).

A Debug build keeps its own library, separate from the released app's, never checks for updates, and by default doesn't sync.

If you open the project in Xcode instead, it may ask you to trust the macros that come with swift-dependencies before it will build.

Use the configurations as they are. A new build configuration builds the packages in release mode, which strips the checks that only run in Debug.

### Running it

An unsigned build carries none of the app's entitlements: no sandbox and no keychain access group. Running one hasn't been checked end to end yet, so features that rely on those entitlements may refuse.

### Signing with your own team

There's no documented road for this yet. The bundle identifiers and keychain groups in the project are mine, so signing with your own team means changing them.

## The iOS app

The iOS app is in development and hasn't been released. It builds for the simulator the same way:

```sh
cd App/Variorum
xcodebuild -scheme VariorumMobile -configuration Debug \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

## What Variorum is built on

Each of these keeps its own license. The versions are pinned in `Package.swift`, `Package.resolved` and the Xcode project.

| Library | Used for | License |
|---|---|---|
| [GRDB.swift](https://github.com/groue/GRDB.swift), from [a fork](https://github.com/lduarte-io/GRDB.swift) with GRDB's documented SQLCipher setup applied | the database layer | MIT |
| [SQLCipher](https://github.com/sqlcipher/SQLCipher.swift) (community edition), which contains SQLite | the encrypted database (prebuilt framework) | BSD-3-Clause; SQLite is public domain |
| [swift-dependencies](https://github.com/pointfreeco/swift-dependencies), with [swift-concurrency-extras](https://github.com/pointfreeco/swift-concurrency-extras), [xctest-dynamic-overlay](https://github.com/pointfreeco/xctest-dynamic-overlay), [combine-schedulers](https://github.com/pointfreeco/combine-schedulers) and [swift-clocks](https://github.com/pointfreeco/swift-clocks) | dependency injection | MIT |
| [swift-syntax](https://github.com/swiftlang/swift-syntax) | swift-dependencies' macros, at build time only | Apache-2.0 |
| [MCP Swift SDK](https://github.com/modelcontextprotocol/swift-sdk), with [swift-log](https://github.com/apple/swift-log), [swift-system](https://github.com/apple/swift-system) and [EventSource](https://github.com/mattt/eventsource) | the MCP server (Mac only) | MIT and Apache-2.0; swift-log and swift-system Apache-2.0; EventSource MIT |
| [swift-nio](https://github.com/apple/swift-nio), [swift-collections](https://github.com/apple/swift-collections), [swift-atomics](https://github.com/apple/swift-atomics) | fetched with the MCP SDK, not part of the app | Apache-2.0 |
| [Sparkle](https://github.com/sparkle-project/Sparkle) | updates for the released Mac app (prebuilt framework) | MIT, with BSD-2-Clause and zlib parts |
| [Argon2](https://github.com/P-H-C/phc-winner-argon2) reference implementation, vendored in `Vendor/CArgon2/` | passphrase key derivation | CC0-1.0 or Apache-2.0 |
| [BIP-39](https://github.com/bitcoin/bips/tree/master/bip-0039) English wordlist, vendored | the twelve words | MIT |
