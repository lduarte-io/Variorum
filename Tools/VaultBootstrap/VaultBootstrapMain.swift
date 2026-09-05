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
        case passphraseFileMissing(String)
        case accessTokenFileMissing(String)

        var description: String {
            switch self {
            case .storeMissing(let path):
                return "no store exists at \(path) — refusing to mint one (check the path)"
            case .passphraseFileMissing(let path):
                return "cannot read the passphrase file at \(path)"
            case .accessTokenFileMissing(let path):
                return "cannot read the access-token file at \(path)"
            }
        }
    }
}
