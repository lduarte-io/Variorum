// dmg-background.swift — Phase 13r U3-A, R-13r-10 (the self-explaining DMG window). It DRAWS the DMG
// window's plain functional background: one arrow from where the app icon sits to where the Applications
// link sits, and one line of words under it. FUNCTIONAL ONLY — the branded art is 13s's (her ruling); this
// file exists so the window explains itself until then, with no new dependency (AppKit drawing, compiled
// by make-dmg.sh with xcrun swiftc, like verify-appcast.swift).
//
//   swiftc -O -o dmg-background Tools/Release/dmg-background.swift
//   dmg-background <out-dir>        → <out-dir>/background.png (660×400) + background@2x.png (1320×800)
//
// The geometry is make-dmg.sh's (the window's content is 660×400 points; the 128-pt icons are CENTRED at
// x 165 and x 495, y 190 — Finder positions an icon by its centre). The arrow spans the gap between the
// two icons; the words sit under it, clear of both icons' labels. Exit 0 = both files written.

import AppKit

let args = CommandLine.arguments
guard args.count == 2 else {
    FileHandle.standardError.write(Data("usage: dmg-background <out-dir>\n".utf8))
    exit(2)
}
let outDir = URL(fileURLWithPath: args[1], isDirectory: true)

/// The window's content size in points, and the icon centres (make-dmg.sh's constants — keep in step).
let size = CGSize(width: 660, height: 400)
let appCentre = CGPoint(x: 165, y: 190)
let linkCentre = CGPoint(x: 495, y: 190)
let words = "Drag Variorum to Applications"

/// Plain, quiet colours: a near-white room and a mid-grey ink.
let room = NSColor(srgbRed: 0.965, green: 0.965, blue: 0.957, alpha: 1)
let ink = NSColor(srgbRed: 0.42, green: 0.42, blue: 0.42, alpha: 1)

func draw(scale: CGFloat, to url: URL) throws {
    let pixels = CGSize(width: size.width * scale, height: size.height * scale)
    guard let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: Int(pixels.width), pixelsHigh: Int(pixels.height),
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)
    else { throw NSError(domain: "dmg-background", code: 1) }
    rep.size = size  // points — so a 2× rep carries 144 dpi
    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: rep) else { throw NSError(domain: "dmg-background", code: 2) }
    NSGraphicsContext.current = context
    // Flip to Finder's top-left coordinates so the icon centres read as make-dmg.sh writes them.
    let transform = NSAffineTransform()
    transform.translateX(by: 0, yBy: size.height)
    transform.scaleX(by: 1, yBy: -1)
    transform.concat()

    room.setFill()
    NSRect(origin: .zero, size: size).fill()

    // The arrow: a shaft across the gap between the icons (each icon is 128 pt wide), and a chevron head.
    let y = appCentre.y
    let start = appCentre.x + 64 + 26
    let end = linkCentre.x - 64 - 26
    ink.setStroke()
    let shaft = NSBezierPath()
    shaft.lineWidth = 4
    shaft.lineCapStyle = .round
    shaft.move(to: CGPoint(x: start, y: y))
    shaft.line(to: CGPoint(x: end, y: y))
    shaft.stroke()
    let head = NSBezierPath()
    head.lineWidth = 4
    head.lineCapStyle = .round
    head.lineJoinStyle = .round
    head.move(to: CGPoint(x: end - 18, y: y - 16))
    head.line(to: CGPoint(x: end, y: y))
    head.line(to: CGPoint(x: end - 18, y: y + 16))
    head.stroke()

    // The words, centred under the arrow (drawn upright inside the flipped space).
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 15, weight: .medium),
        .foregroundColor: ink,
        .paragraphStyle: paragraph,
    ]
    let text = NSAttributedString(string: words, attributes: attributes)
    let box = CGRect(x: 0, y: y + 34, width: size.width, height: 24)
    NSGraphicsContext.current?.cgContext.saveGState()
    // Un-flip locally for text so glyphs are not mirrored.
    let flipBack = NSAffineTransform()
    flipBack.translateX(by: 0, yBy: box.midY)
    flipBack.scaleX(by: 1, yBy: -1)
    flipBack.translateX(by: 0, yBy: -box.midY)
    flipBack.concat()
    text.draw(in: box)
    NSGraphicsContext.current?.cgContext.restoreGState()

    NSGraphicsContext.restoreGraphicsState()
    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "dmg-background", code: 3)
    }
    try png.write(to: url)
}

do {
    try draw(scale: 1, to: outDir.appendingPathComponent("background.png"))
    try draw(scale: 2, to: outDir.appendingPathComponent("background@2x.png"))
    print("dmg-background: wrote background.png + background@2x.png (\(Int(size.width))×\(Int(size.height)) pt)")
} catch {
    FileHandle.standardError.write(Data("dmg-background: \(error)\n".utf8))
    exit(1)
}
