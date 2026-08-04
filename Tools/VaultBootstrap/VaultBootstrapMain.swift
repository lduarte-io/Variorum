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
//    --store <path>            the SQLite store (must already exist)
//    --passphrase-file <path>  bytes = the passphrase; one trailing newline
//                              stripped; NEVER printed or logged
//    --project-url <url>       https://<project>.supabase.co
//    --api-key <key>           the publishable API key
//    --access-token <jwt>      a SHORT-LIVED access token (architect-minted)
//    --dry-run                 print the plan; write nothing
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
        guard
            let storePath = value(of: "--store"),
            let passphraseFile = value(of: "--passphrase-file"),
            let projectURLString = value(of: "--project-url"),
            let projectURL = URL(string: projectURLString),
            let apiKey = value(of: "--api-key"),
            let accessToken = value(of: "--access-token")
        else {
            FileHandle.standardError.write(Data("""
                usage: vault-bootstrap --store <path> --passphrase-file <path> \
                --project-url <url> --api-key <key> --access-token <jwt> [--dry-run]

                """.utf8))
            exit(2)
        }

        // The store must EXIST — a mistyped path must never mint an empty
        // store and "succeed" (this tool points at her real corpus).
        guard FileManager.default.fileExists(atPath: storePath) else {
            throw CLIError.storeMissing(storePath)
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

        let database = try AppDatabase.openStore(at: URL(fileURLWithPath: storePath))
        let sessionProvider = StaticSessionProvider(
            session: UserSession(accessToken: accessToken, userID: userID))
        let bootstrap = VaultBootstrap(
            client: KeyVaultClient(
                configuration: KeyVaultClient.Configuration(
                    projectURL: projectURL, apiKey: apiKey),
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
        case passphraseFileMissing(String)

        var description: String {
            switch self {
            case .storeMissing(let path):
                return "no store exists at \(path) — refusing to mint one (check the path)"
            case .passphraseFileMissing(let path):
                return "cannot read the passphrase file at \(path)"
            }
        }
    }
}
