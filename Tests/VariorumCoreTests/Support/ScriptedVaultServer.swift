import Foundation
@testable import VariorumCore

/// A scripted PostgREST responder for `key_vault` (Phase 14b batch 3): the
/// no-network test double the vault client, the enrollment flows, and the
/// vault-bootstrap runner all script against. Models exactly what the
/// deployed table does — one row per user, PK refusal on duplicate insert,
/// filter-miss on update — plus the auth arms (401 on a wrong bearer, for
/// the refresh-and-retry pin). Never a network socket.
final class ScriptedVaultServer: @unchecked Sendable {
    private let lock = NSLock()
    private var rowsByUser: [String: KeyVaultWireRow] = [:]
    private(set) var requestCount = 0
    private(set) var getCount = 0
    private(set) var postCount = 0
    private(set) var patchCount = 0
    /// When set, requests whose bearer differs answer 401 (the stale-token
    /// arm; the retry with a refreshed session then succeeds).
    var requiredBearer: String?
    /// When set, EVERY request answers this status with an empty body
    /// (server-down arms).
    var forcedStatus: Int?

    init() {}

    /// Seed a stored row directly (e.g. a newer-format vault).
    func store(_ row: KeyVaultWireRow) {
        lock.lock()
        defer { lock.unlock() }
        rowsByUser[row.userID] = row
    }

    func storedRow(userID: String) -> KeyVaultWireRow? {
        lock.lock()
        defer { lock.unlock() }
        return rowsByUser[userID]
    }

    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return rowsByUser.isEmpty
    }

    /// The injectable `load` closure for `KeyVaultClient`.
    var load: @Sendable (URLRequest) async throws -> (Data, URLResponse) {
        { [weak self] request in
            guard let self else { throw URLError(.cancelled) }
            return self.respond(to: request)
        }
    }

    private func respond(to request: URLRequest) -> (Data, URLResponse) {
        lock.lock()
        defer { lock.unlock() }
        requestCount += 1

        func response(_ status: Int, body: Data = Data()) -> (Data, URLResponse) {
            (body, HTTPURLResponse(
                url: request.url!, statusCode: status, httpVersion: "HTTP/1.1",
                headerFields: nil)!)
        }

        if let forcedStatus { return response(forcedStatus) }
        if let requiredBearer {
            let bearer = request.value(forHTTPHeaderField: "Authorization") ?? ""
            guard bearer == "Bearer \(requiredBearer)" else {
                return response(401, body: Data(#"{"message":"JWT expired"}"#.utf8))
            }
        }
        guard let url = request.url,
              url.path.hasSuffix("/rest/v1/key_vault")
        else { return response(404) }

        let filteredUser = userFilter(url)

        switch request.httpMethod {
        case "GET":
            getCount += 1
            guard let filteredUser else { return response(400) }
            let rows = rowsByUser[filteredUser].map { [$0] } ?? []
            return response(200, body: try! JSONEncoder().encode(rows))
        case "POST":
            postCount += 1
            guard let body = request.httpBody,
                  let row = try? JSONDecoder().decode(KeyVaultWireRow.self, from: body)
            else { return response(400) }
            guard rowsByUser[row.userID] == nil else {
                // PostgREST duplicate key: HTTP 409, SQLSTATE 23505.
                return response(409, body: Data(
                    #"{"code":"23505","message":"duplicate key value violates unique constraint \"key_vault_pkey\""}"#
                        .utf8))
            }
            rowsByUser[row.userID] = row
            return response(201)
        case "PATCH":
            patchCount += 1
            guard let filteredUser,
                  let body = request.httpBody,
                  let row = try? JSONDecoder().decode(KeyVaultWireRow.self, from: body)
            else { return response(400) }
            guard rowsByUser[filteredUser] != nil else {
                // No row matched the filter: 200 with an empty representation.
                return response(200, body: Data("[]".utf8))
            }
            rowsByUser[filteredUser] = row
            return response(200, body: try! JSONEncoder().encode([row]))
        default:
            return response(405)
        }
    }

    private func userFilter(_ url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let item = components.queryItems?.first(where: { $0.name == "user_id" }),
              let value = item.value, value.hasPrefix("eq.")
        else { return nil }
        return String(value.dropFirst(3))
    }
}

/// One scripted vault world: server + client + enrollment, under a fixed
/// signed-in session.
struct VaultTestWorld {
    let server: ScriptedVaultServer
    let client: KeyVaultClient
    let enrollment: VaultEnrollment
    let userID: String

    init(userID: String = "user-vault-test", accessToken: String = "token-1") {
        let server = ScriptedVaultServer()
        let client = KeyVaultClient(
            configuration: KeyVaultClient.Configuration(
                projectURL: URL(string: "https://vault.test.invalid")!,
                apiKey: "publishable-test-key"),
            sessionProvider: StaticSessionProvider(
                session: UserSession(accessToken: accessToken, userID: userID)),
            load: server.load)
        self.server = server
        self.client = client
        self.enrollment = VaultEnrollment(client: client)
        self.userID = userID
    }
}
