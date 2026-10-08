//
//  vault-bootstrap — Phase 14b's headless maintenance executable (L10).
//
//  The Round-5 overnight arrangement's executor: create-or-unwrap the
//  account's key vault, resyncReinitialize the store, and repush the whole
//  corpus through the encrypting serializer until the outbox drains. Run
//  by the ARCHITECT at the gate, behind the A1 rail, AFTER the mirror's
//  data-table truncate (the R-2 choreography) — never linked into any app.
//
//  Inputs (no defaults touch production — every coordinate is explicit):
//    --store <path>              the SQLite store (must already exist)
//    --passphrase-file <path>    bytes = the passphrase; one trailing newline
//                                stripped; NEVER printed or logged
//    --project-url <url>         https://<project>.supabase.co
//    --api-key <key>             the publishable API key
//    --access-token <jwt>        a SHORT-LIVED access token (architect-minted;
//                                argv is `ps`-visible — prefer the file form)
//    --access-token-file <path>  R1-8: bytes = the token, one trailing
//                                newline stripped, never printed. EXACTLY ONE
//                                of --access-token / --access-token-file is
//                                required (the gate uses the file form)
//    --dry-run                   print the plan; write nothing
//
//  Keys live in memory only and die with this process. Custody (Keychain)
//  is the app's enrollment act, never this tool's.
//

import Foundation
import VariorumCore

@main
enum VaultBootstrapCLI {
    static func main() async {
        do {
            try await run()
        } catch {
            FileHandle.standardError.write(Data("vault-bootstrap: \(error)\n".utf8))
            exit(1)
        }
    }

    private static func run() async throws {
        let arguments = CommandLine.arguments
        func value(of flag: String) -> String? {
            guard let index = arguments.firstIndex(of: flag),
                  index + 1 < arguments.count else { return nil }
            return arguments[index + 1]
        }
        let dryRun = arguments.contains("--dry-run")
        let tokenArgument = value(of: "--access-token")
        let tokenFile = value(of: "--access-token-file")
        guard
            let storePath = value(of: "--store"),
            let passphraseFile = value(of: "--passphrase-file"),
            let projectURLString = value(of: "--project-url"),
            let projectURL = URL(string: projectURLString),
            let apiKey = value(of: "--api-key"),
            // R1-8: exactly ONE of the two token doors — argv (retained,
            // `ps`-visible) or the file form (the gate's).
            (tokenArgument != nil) != (tokenFile != nil)
        else {
            FileHandle.standardError.write(Data("""
                usage: vault-bootstrap --store <path> --passphrase-file <path> \
                --project-url <url> --api-key <key> \
                (--access-token <jwt> | --access-token-file <path>) [--dry-run]
                note: exactly one of --access-token / --access-token-file

                """.utf8))
            exit(2)
        }
        let accessToken: String
        if let tokenFile {
            let tokenData: Data
            do {
                tokenData = try Data(contentsOf: URL(fileURLWithPath: tokenFile))
            } catch {
                throw CLIError.accessTokenFileMissing(tokenFile)
            }
            accessToken = try VaultBootstrap.accessToken(fromFileBytes: tokenData)
        } else {
            accessToken = tokenArgument!
        }

        // The store must EXIST — a mistyped path must never mint an empty
        // store and "succeed" (this tool points at her real corpus).
        guard FileManager.default.fileExists(atPath: storePath) else {
            throw CLIError.storeMissing(storePath)
        }
        let storeURL = URL(fileURLWithPath: storePath)
        // VX-64 (Phase 13x U1 row 5) — THE STOREUNLOCK ROAD. The bare
        // `openStore(at:)` this tool shipped with resolves the AMBIENT
        // `\.storeKeyCustody` — the REAL store's device-Keychain item,
        // unreadable from an unsigned CLI and the wrong store besides —
        // so on every encrypted store `resolveStoreKey` refused
        // `keyUnavailable` and the tool could not run headless at all.
        // The proven road (StringsWorkbook's `StoreUnlock`): the key file
        // beside the store + the typed secret the tool ALREADY takes
        // (`--passphrase-file` — the same passphrase the vault arms need)
        // + in-memory custody. No Keychain is consulted; the key lives in
        // this process's memory and dies with it. The tool now also
        // REFUSES a plaintext store outright: it must never be the thing
        // that runs the one-time encryption migration on a library.
        guard StoreFilePresence.classify(at: storeURL) == .encryptedOrUnknown else {
            throw CLIError.storeNotEncrypted(storePath)
        }
        let passphraseData: Data
        do {
            passphraseData = try Data(contentsOf: URL(fileURLWithPath: passphraseFile))
        } catch {
            throw CLIError.passphraseFileMissing(passphraseFile)
        }
        let passphrase = try VaultBootstrap.passphrase(fromFileBytes: passphraseData)
        let userID = try VaultBootstrap.subject(ofAccessToken: accessToken)

        print("vault-bootstrap: store \(storePath)")
        print("vault-bootstrap: project \(projectURL.absoluteString), session user \(userID)\(dryRun ? " — DRY RUN" : "")")

        let storeKey: StoreKey
        do {
            guard let envelope = try StoreKeyEnvelope.loadCurrent(besideStore: storeURL) else {
                throw CLIError.noKeyFile(storeURL.deletingLastPathComponent().path)
            }
            guard envelope.passphrase != nil else {
                throw CLIError.noPassphraseRoad
            }
            // Argon2id at the file's own descriptor (floor-checked) —
            // RFC 3394 refuses a wrong word, never yields garbage bytes.
            storeKey = try envelope.unwrapKey(passphrase: passphrase)
        } catch StoreKeyEnvelopeError.wrongPassphrase {
            throw CLIError.wrongPassphrase
        } catch let error as StoreKeyEnvelopeError {
            throw CLIError.keyFileUnreadable(String(describing: error))
        }
        print("vault-bootstrap: store unlocked by the key file's passphrase road "
            + "(key \(StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: storeKey)))…; "
            + "no Keychain consulted)")
        let database = try AppDatabase.openStore(
            at: storeURL, custody: .inMemory(initial: storeKey))
        let sessionProvider = StaticSessionProvider(
            session: UserSession(accessToken: accessToken, userID: userID))
        let bootstrap = VaultBootstrap(
            client: KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: projectURL, apiKey: apiKey,
                    // pre-13x 2c (decision 34): the tool names the Mac it runs on.
                    deviceName: Host.current().localizedName ?? "vault-bootstrap"),
                sessionProvider: sessionProvider),
            transport: SupabaseTransport(
                configuration: SupabaseTransport.Configuration(
                    projectURL: projectURL, apiKey: apiKey),
                sessionProvider: sessionProvider),
            database: database,
            log: { print("vault-bootstrap: \($0)") })

        _ = try await bootstrap.run(passphrase: passphrase, dryRun: dryRun)
        print("vault-bootstrap: done.")
    }

    enum CLIError: Error, CustomStringConvertible {
        case storeMissing(String)
        case storeNotEncrypted(String)
        case noKeyFile(String)
        case noPassphraseRoad
        case wrongPassphrase
        case keyFileUnreadable(String)
        case passphraseFileMissing(String)
        case accessTokenFileMissing(String)

        var description: String {
            switch self {
            case .storeMissing(let path):
                return "no store exists at \(path) — refusing to mint one (check the path)"
            case .storeNotEncrypted(let path):
                return "\(path) is not an encrypted Variorum store — this tool opens only an "
                    + "already-encrypted library and never runs the encryption migration"
            case .noKeyFile(let folder):
                return "no key file (variorum-keys-….json) sits beside the store in \(folder)"
            case .noPassphraseRoad:
                return "this library's key file holds no passphrase copy — set an encryption "
                    + "passphrase in the app first"
            case .wrongPassphrase:
                return "that passphrase does not unlock this library (nothing was opened)"
            case .keyFileUnreadable(let reason):
                return "the key file beside the store could not be used: \(reason)"
            case .passphraseFileMissing(let path):
                return "cannot read the passphrase file at \(path)"
            case .accessTokenFileMissing(let path):
                return "cannot read the access-token file at \(path)"
            }
        }
    }
}
