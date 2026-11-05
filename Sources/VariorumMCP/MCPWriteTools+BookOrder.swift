import Foundation
import GRDB
import MCP
import VariorumCore

/// **`set_book_order` — a book's order on the wire** (VX-813 — the VX-809 run,
/// batch 2; her ruling R-813: "order is plain book configuration; her state
/// doors (Finished, Seal, Own, Private) stay hers alone. An order option on
/// create_book and set_book_rule too, not only a standalone setter").
///
/// HER door is the book view navigator's `order ▾` → "Save as This Book's
/// Order" (`setReadingSort`), drawn on a book AND a gathering — so the act is
/// decided at EDIT on the book, or on the gathering PLACE (VX-639's
/// `onBookOrGathering`: its own grant or its wing's, R-VX184-1's parity — a
/// refusal her door doesn't have would be wrong). Her op's one refusal speaks:
/// a finished (so also sealed) book (`lockedReading`, her table's words). The
/// order already as asked answers `changed: false` — nothing written, no undo
/// entry, no receipt (the VX-362 posture). ONE client-named undo entry
/// otherwise (`Operations.setBookOrderForClient`, compare-and-set both ways).
///
/// The `order` OPTIONS (R-813's fuller paste) parse through the same one
/// grammar (`order(field:direction:at:)`): `create_book`'s is write new (a new,
/// empty book's birth configuration); `set_book_rule`'s decides the book at
/// EDIT (A-809-17 — `insert_blocks`' rung-by-argument precedent, so the option
/// is never a write-new back door around this tool's rung).
extension MCPWriteTools {
    /// The wire's names for the order's two columns — the stored spellings
    /// (`sort_field`'s CHECK values; `asc` / `desc`), never a label.
    static let orderFields = ["manual", "entry_date", "created_at", "last_touched", "last_major_revision"]
    static let orderDirections = ["asc", "desc"]

    /// **The ONE order grammar** — `sort_field` (required) and `sort_dir`
    /// (`asc` when omitted — the column's own default; `manual` reads as the
    /// book's hand order whatever the direction, so its direction is never
    /// asked for). Any field × direction her op takes (her menu offers seven
    /// of the ten pairs; an unlisted pair still reads with a name there).
    /// `at` prefixes the argument names in a refusal (`""` for the standalone
    /// tool, `"order."` for the options).
    static func order(field: Value?, direction: Value?, at prefix: String) throws -> Queries.ReadingOrder {
        guard let field, field != .null else {
            throw ArgumentFailure(message: "\(prefix)sort_field is required: \(orderFieldList).")
        }
        guard let fieldWord = field.stringValue, let sortField = SortField(rawValue: fieldWord) else {
            throw ArgumentFailure(message: "\(prefix)sort_field must be one of \(orderFieldList).")
        }
        guard let direction, direction != .null else {
            return Queries.ReadingOrder(field: sortField, direction: .asc)
        }
        guard let directionWord = direction.stringValue, let sortDir = SortDirection(rawValue: directionWord) else {
            throw ArgumentFailure(message: "\(prefix)sort_dir must be \"asc\" or \"desc\".")
        }
        return Queries.ReadingOrder(field: sortField, direction: sortDir)
    }

    private static var orderFieldList: String {
        orderFields.map { "\"\($0)\"" }.joined(separator: ", ")
    }

    /// `create_book`'s and `set_book_rule`'s optional `order` object —
    /// `{"sort_field": …, "sort_dir": …}`, exactly `set_book_order`'s two
    /// arguments; nil when absent (or null).
    func orderOption(_ args: [String: Value]) throws -> Queries.ReadingOrder? {
        guard let value = args["order"], value != .null else { return nil }
        guard let object = value.objectValue else {
            throw ArgumentFailure(message: "order must be an object: {\"sort_field\": …, \"sort_dir\": …}.")
        }
        // An unknown key inside it never gets here: VX-606's one check at the
        // call door refuses an undeclared argument at any depth the schema
        // declares (`orderOption`'s `additionalProperties: false`).
        return try Self.order(field: object["sort_field"], direction: object["sort_dir"], at: "order.")
    }

    /// The order as every answer spells it.
    static func orderAnswer(_ order: Queries.ReadingOrder) -> [String: Any] {
        ["sort_field": order.field.rawValue, "sort_dir": order.direction.rawValue]
    }

    func performBookOrder(
        bookID: String, order: Queries.ReadingOrder, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let label = { (act: Operations.MCPWriteAct) in act.undoLabel(client: clientName) }
        return try onBookOrGathering(bookID, rung: .edit, job: job, clientName: clientName) { name, place in
            let act: Operations.MCPWriteAct = place == .gathering ? .gatheringSort : .bookSort
            let result = try ops.setBookOrderForClient(
                bookID, order: order, undoLabel: label(act), guardedBy: guardPlace(clientName, place, bookID))
            return (["book_id": bookID, "order": Self.orderAnswer(result.order), "changed": result.changed],
                    result.changed
                        ? MCPWriteReceipt(clientName: clientName, act: act, targetID: bookID, targetTitle: name,
                                          show: .book(bookID: bookID, sectionID: nil))
                        : nil)
        }
    }
}
