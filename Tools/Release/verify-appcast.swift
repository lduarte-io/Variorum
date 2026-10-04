// verify-appcast.swift — Phase 13r U2: prove an appcast item is exactly what a shipped Variorum will
// accept, BEFORE anything is published. It reads files only.
//
//   swiftc -O -o verify-appcast Tools/Release/verify-appcast.swift
//   verify-appcast <appcast.xml> <dmg> <url-prefix> <version> <build> <base64-public-key> [<notes.md>]
//
// It checks the item whose sparkle:version is <build>:
//   · sparkle:shortVersionString = <version>
//   · enclosure url = <url-prefix> + the DMG's file name (exactly; the site's rate limit keys on
//     the "Variorum-<version>.dmg" name, and a published URL is immutable)
//   · enclosure length = the DMG's byte size (the site's rule)
//   · sparkle:edSignature VERIFIES over the DMG's bytes under <base64-public-key>, which is the
//     SUPublicEDKey baked into the app. This is the end-to-end proof that the private key
//     generate_appcast read from her Keychain is the twin of the shipped public key (standard
//     Ed25519, which Sparkle uses; CryptoKit verifies it independently of Sparkle's code).
//   · its build is STRICTLY the highest in the feed (so Sparkle offers it to every older install)
//   · no delta items (the handoff is "appcast.xml + the DMG", nothing else to upload)
//   · U3-A: when <notes.md> is given (non-empty), the item's <description sparkle:format="markdown">
//     carries EXACTLY that text — the ONE release-notes source the in-app What's New also reads
// Exit 0 = every check passed · 1 = a check failed · 2 = usage or unreadable input.

import CryptoKit
import Foundation

var failures = 0
func ok(_ s: String) { print("PASS  \(s)") }
func bad(_ s: String) { print("FAIL  \(s)"); failures += 1 }

let args = CommandLine.arguments
guard args.count == 7 || args.count == 8 else {
    FileHandle.standardError.write(Data("usage: verify-appcast <appcast.xml> <dmg> <url-prefix> <version> <build> <base64-public-key> [<notes.md>]\n".utf8))
    exit(2)
}
let (appcastPath, dmgPath, prefix, version, build, publicKeyB64) = (args[1], args[2], args[3], args[4], args[5], args[6])
let notesPath: String? = args.count == 8 && !args[7].isEmpty ? args[7] : nil

guard let doc = try? XMLDocument(contentsOf: URL(fileURLWithPath: appcastPath), options: []) else {
    FileHandle.standardError.write(Data("cannot parse \(appcastPath)\n".utf8)); exit(2)
}
guard let dmg = FileManager.default.contents(atPath: dmgPath) else {
    FileHandle.standardError.write(Data("cannot read \(dmgPath)\n".utf8)); exit(2)
}
guard let keyBytes = Data(base64Encoded: publicKeyB64), keyBytes.count == 32,
      let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: keyBytes) else {
    FileHandle.standardError.write(Data("the public key is not a 32-byte Ed25519 key\n".utf8)); exit(2)
}

/// A child element's text by LOCAL name (sparkle:version → "version"), namespace-agnostic.
func child(_ element: XMLElement, _ local: String) -> XMLElement? {
    element.children?.compactMap { $0 as? XMLElement }.first { $0.localName == local }
}
/// An attribute by local name (sparkle:edSignature → "edSignature").
func attribute(_ element: XMLElement, _ local: String) -> String? {
    element.attributes?.first { $0.localName == local }?.stringValue
}
/// The item's build: the sparkle:version element (Sparkle 2's form) or the enclosure attribute.
func buildOf(_ item: XMLElement) -> String? {
    child(item, "version")?.stringValue ?? child(item, "enclosure").flatMap { attribute($0, "version") }
}

let items = ((try? doc.nodes(forXPath: "//item")) ?? []).compactMap { $0 as? XMLElement }
print("== verify-appcast: \(appcastPath) · \(items.count) item(s) · looking for build \(build)")
guard let item = items.first(where: { buildOf($0) == build }) else {
    bad("no item with sparkle:version \(build)")
    print("VERDICT: FAIL"); exit(1)
}
ok("an item with sparkle:version = \(build)")

let short = child(item, "shortVersionString")?.stringValue
    ?? child(item, "enclosure").flatMap { attribute($0, "shortVersionString") }
if short == version { ok("sparkle:shortVersionString = \(version)") }
else { bad("sparkle:shortVersionString = '\(short ?? "nil")' (expected '\(version)')") }

guard let enclosure = child(item, "enclosure") else {
    bad("the item has no enclosure"); print("VERDICT: FAIL"); exit(1)
}
let dmgName = URL(fileURLWithPath: dmgPath).lastPathComponent
let expectedURL = prefix + dmgName
let url = attribute(enclosure, "url")
if url == expectedURL { ok("enclosure url = \(expectedURL)") }
else { bad("enclosure url = '\(url ?? "nil")' (expected '\(expectedURL)')") }

let length = attribute(enclosure, "length")
if length == String(dmg.count) { ok("enclosure length = \(dmg.count) bytes (the DMG's size)") }
else { bad("enclosure length = '\(length ?? "nil")' (the DMG is \(dmg.count) bytes)") }

if let sigB64 = attribute(enclosure, "edSignature"), let signature = Data(base64Encoded: sigB64) {
    if publicKey.isValidSignature(signature, for: dmg) {
        ok("sparkle:edSignature VERIFIES over the DMG's bytes under the baked SUPublicEDKey")
    } else {
        bad("sparkle:edSignature does NOT verify under the baked SUPublicEDKey — the key pair is wrong or the DMG changed after signing")
    }
} else {
    bad("the enclosure carries no sparkle:edSignature")
}

let others = items.filter { $0 !== item }.compactMap { buildOf($0).flatMap { Int($0) } }
if let mine = Int(build), others.allSatisfy({ $0 < mine }) {
    ok("build \(build) is strictly the highest in the feed (others: \(others.sorted().map(String.init).joined(separator: ", ")))")
} else {
    bad("build \(build) is NOT strictly the highest (others: \(others)) — Sparkle would not offer it")
}

// U3-A — the ONE release-notes source, embedded as the item's Markdown description.
let description = child(item, "description")
if let notesPath {
    guard let notes = try? String(contentsOfFile: notesPath, encoding: .utf8) else {
        FileHandle.standardError.write(Data("cannot read \(notesPath)\n".utf8)); exit(2)
    }
    let embedded = description?.stringValue ?? ""
    let trim: (String) -> String = { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    if !trim(notes).isEmpty, trim(embedded) == trim(notes) {
        ok("the item's description is the release notes, verbatim (\(notes.utf8.count) bytes)")
    } else {
        bad("the item's description is not the release notes (\(embedded.utf8.count) bytes embedded)")
    }
    let format = description.flatMap { attribute($0, "format") }
    if format == "markdown" { ok("the description is sparkle:format=\"markdown\" (Sparkle renders it natively)") }
    else { bad("the description's sparkle:format is '\(format ?? "nil")' (expected 'markdown')") }
} else {
    ok("no release notes expected for this item\(description == nil ? "" : " (it carries a description anyway)")")
}

let deltas = (try? doc.nodes(forXPath: "//*[local-name()='deltas']")) ?? []
if deltas.isEmpty { ok("no delta items (the handoff is appcast.xml + the DMG only)") }
else { bad("the feed carries \(deltas.count) <sparkle:deltas> block(s) — generate_appcast must run with --maximum-deltas 0") }

print("==")
print(failures == 0 ? "VERDICT: PASS" : "VERDICT: FAIL — \(failures) check(s) failed")
exit(failures == 0 ? 0 : 1)
