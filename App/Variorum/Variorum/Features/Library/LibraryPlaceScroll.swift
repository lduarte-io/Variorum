//
//  LibraryPlaceScroll.swift
//  Variorum (Mac)
//
//  **VX-823 (the VX-828 run, batch C) — the VIEW's half of "the Library
//  remembers where you were."** The pure brain is `LibraryPlace.swift`; what
//  outlives the view (the place, the mark, the return's re-ask) is
//  `LibraryCatalogPlace.swift`. Applied to each of the Library's three scroll
//  views — the List's column, the Cards, the answer sheet — this does three
//  things, and reads the store for none of them:
//
//  1. **It reports what a place is made of.** Every row reports its frame in
//     its column's CONTENT space (`libraryPlaceRow` — the value moves only when
//     layout above the row moves, never per scroll frame), and the scroll view
//     its window (`onScrollGeometryChange`, held by reference — the Open list's
//     `SidebarSectionWindow` posture: a scroll re-renders nothing).
//  2. **It notes the place when her scroll RESTS** — one coalesced task per
//     burst (`restInterval` of stillness) — so every road out of the Library
//     finds it noted (P-828-13), and nothing is read during teardown, whose
//     `onDisappear` order is not ours to assume.
//  3. **It lands a return, UNBOUND.** As soon as a pane that remembers a
//     place has its proxy and a viewport height — the scroll view's OWN frame,
//     which reports at mount; never waiting for a scroll READING, which arrives
//     only when the scroll geometry CHANGES (the walk's red, window 1: a short
//     listing whose geometry never changed after the return mount landed
//     nowhere — see the record): one `ScrollViewReader.scrollTo(row, anchor:)`,
//     unanimated (the Open list's road; Takes measured the proxy honouring
//     `into / (viewport − height)`), on the rows the model still holds — then
//     a short HOLD that re-checks the row's report a few times while the lazy
//     column settles, and once more when the return's in-place re-ask lands
//     (the model's token), re-aiming only while the row is off its place. Her
//     hand (`onScrollPhaseChange` interacting / decelerating — the sidebar's
//     measured rule) ends the hold at once. **The 18l-c U8 trap, designed
//     around:** no `.scrollPosition` binding exists here, so nothing re-applies
//     a stale target over her hand on a relayout, and a pin can stage a scroll
//     through `NSClipView` (the trap bites only BOUND scroll views).
//

import SwiftUI

extension LibraryPlace.Window {
    /// A scroll view's reading, in its content's space.
    nonisolated init(_ geometry: ScrollGeometry) {
        self.init(
            offset: geometry.visibleRect.minY,
            viewport: geometry.visibleRect.height,
            content: geometry.contentSize.height)
    }
}

extension LibraryPlace {
    /// The coordinate space each scroll view's CONTENT is named — the rows'
    /// frames are read in it (one name; each scroll view's rows resolve to
    /// their own nearest content).
    static let contentSpace = "library-place-content"
}

extension View {
    /// VX-823: on one of the Library's scroll views (outermost on the
    /// `ScrollView`, the scroll readers beside it).
    func libraryPlaceScroll(
        _ model: LibraryCatalogModel, key: String, surface: LibraryPlace.Surface
    ) -> some View {
        modifier(LibraryPlaceScroll(model: model, key: key, surface: surface))
    }

    /// VX-823: on each row a place may name — its frame in the content's space.
    func libraryPlaceRow(_ id: String, memory: LibraryPlaceMemory, key: String) -> some View {
        modifier(LibraryPlaceRow(id: id, memory: memory, key: key))
    }
}

/// A row's report: its frame in its column's content space, dropped when it
/// leaves the screen.
struct LibraryPlaceRow: ViewModifier {
    let id: String
    let memory: LibraryPlaceMemory
    let key: String

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: CGRect.self) {
                $0.frame(in: .named(LibraryPlace.contentSpace))
            } action: { frame in
                memory.noteFrame(frame, id: id, key: key)
            }
            .onDisappear { memory.forgetFrame(id: id, key: key) }
    }
}

/// The scroll view's side: its proxy, its hold, its rest watch — held by
/// REFERENCE, so the scroll's every frame re-renders nothing.
@MainActor
final class LibraryPlaceScrollMemory {
    var proxy: ScrollViewProxy?
    /// THIS mount's reading (the model's per-pane copy may be a previous
    /// mount's until this one's first reading arrives).
    var window = LibraryPlace.Window.unmeasured
    /// THIS mount's scroll view's own height — reported at mount by its frame
    /// (`onGeometryChange` calls its action for the first value; a scroll
    /// READING arrives only when the scroll geometry changes).
    var height: CGFloat = 0
    /// Between this mount's appear and its disappear: only a live surface
    /// notes a place (a reading or a rest during teardown never does).
    var live = false
    /// Whether this mount has asked the model if a return is owed (decided
    /// once — on the first reading or the appear, whichever comes first).
    var decided = false
    /// A return lands on the first MEASURED reading with a proxy in hand.
    var landingOwed = false
    /// From the return's landing until her hand, or until the hold's checks
    /// are done AND the re-ask has landed: her rests note nothing meanwhile.
    var holding = false
    var landing: LibraryPlace.Landing?
    var aims = 0
    /// Each landing or re-aim cycle is an episode; a later one supersedes the
    /// checks an earlier one scheduled.
    var episode = 0
    var checks: Task<Void, Never>?
    var lastMotion = ContinuousClock.now
    var restWatch: Task<Void, Never>?

    func cancel() {
        live = false
        checks?.cancel()
        checks = nil
        restWatch?.cancel()
        restWatch = nil
    }
}

struct LibraryPlaceScroll: ViewModifier {
    let model: LibraryCatalogModel
    let key: String
    let surface: LibraryPlace.Surface

    @State private var memory = LibraryPlaceScrollMemory()

    /// How long her scroll must be still before the place is noted.
    static let restInterval = Duration.milliseconds(150)
    /// The hold's re-checks after each aim, from the aim (the lazy column
    /// settles its estimates over a few passes).
    static let holdChecks: [Duration] = [.milliseconds(40), .milliseconds(120), .milliseconds(300), .milliseconds(650)]
    /// At most this many aims per return — bounded, as the Takes restore is.
    static let aimBudget = 12

    /// Her hand on the scroll (the sidebar's measured rule, U1d): a wheel
    /// burst, a trackpad gesture, the scroller, and their momentum. The
    /// landing's unanimated `scrollTo` reports no phase.
    static func isHandScroll(_ phase: ScrollPhase) -> Bool {
        phase == .interacting || phase == .decelerating
    }

    func body(content: Content) -> some View {
        ScrollViewReader { proxy in
            content
                .onAppear {
                    memory.proxy = proxy
                    memory.live = true
                    model.placeMemory.noteSurface(surface, key: key)
                    decide()
                    trace("appear owed=\(memory.landingOwed) height=\(memory.height)"
                        + " window=\(memory.window.isMeasured)")
                    landIfReady("appear")
                }
                // The viewport, at mount: the scroll view's own height.
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                    memory.height = height
                    landIfReady("height")
                }
                .onScrollGeometryChange(for: LibraryPlace.Window.self) {
                    LibraryPlace.Window($0)
                } action: { old, new in
                    reading(old: old, new: new)
                }
                .onScrollPhaseChange { _, phase in
                    guard Self.isHandScroll(phase) else { return }
                    // Her hand: the list is hers from here.
                    memory.landingOwed = false
                    endHold()
                }
                // The return's in-place re-ask landed: re-resolve against the
                // fresh rows while the hold stands.
                .onChange(of: model.placeMemory.relistedToken(key)) {
                    guard memory.holding || memory.landingOwed else { return }
                    trace("relisted owed=\(memory.landingOwed) holding=\(memory.holding)")
                    if memory.landingOwed {
                        landIfReady("relisted")
                    } else {
                        reaim()
                    }
                }
                .onDisappear { memory.cancel() }
        }
    }

    /// Once per mount: a pane whose model remembers a place — in this wing, on
    /// this kind of scroll view — owes a landing.
    private func decide() {
        guard !memory.decided else { return }
        memory.decided = true
        memory.landingOwed = model.owesReturn(placeKey: key, surface: surface)
        memory.holding = memory.landingOwed
        trace("decide owed=\(memory.landingOwed) remembered="
            + "\(model.placeMemory.place(key)?.place.rows.first?.id ?? "nothing")")
    }

    /// The viewport this mount lands against: its reading's, else its own
    /// frame's height (both are the scroll view's visible height — no inset
    /// sits on these scroll views).
    private var viewport: CGFloat {
        memory.window.isMeasured ? memory.window.viewport : memory.height
    }

    /// Land a return as soon as it can be: owed, a proxy, a viewport.
    private func landIfReady(_ trigger: String) {
        guard memory.landingOwed, memory.proxy != nil, viewport > 0 else { return }
        trace("land(\(trigger))")
        land()
    }

    private func reading(old: LibraryPlace.Window, new: LibraryPlace.Window) {
        memory.window = new
        model.placeMemory.noteWindow(new, surface: surface, key: key)
        decide()
        if memory.landingOwed {
            landIfReady("reading")
            return
        }
        if memory.holding {
            // The column re-laid out under the landing: check it now.
            if new.viewport != old.viewport || new.content != old.content { check() }
            return
        }
        if new.offset != old.offset, memory.live { armRest() }
    }

    // MARK: - The landing and its hold

    private func land() {
        memory.landingOwed = false
        memory.landing = model.placeLanding(placeKey: key)
        trace("landing \(memory.landing.map { "\($0.id) into \($0.into)" } ?? "nil — the top")")
        guard memory.landing != nil else {
            // Nothing she was looking at survives: the top (no aim), and the
            // hold ends once the re-ask is in.
            finishHoldIfDone()
            return
        }
        aim()
        scheduleChecks()
    }

    private func reaim() {
        memory.landing = model.placeLanding(placeKey: key)
        guard memory.landing != nil else {
            finishHoldIfDone()
            return
        }
        aim()
        scheduleChecks()
    }

    private func aim() {
        let viewport = viewport
        guard let landing = memory.landing, let proxy = memory.proxy, viewport > 0,
              memory.aims < Self.aimBudget
        else { return }
        memory.aims += 1
        let anchor = LibraryPlace.anchorY(
            into: landing.into, height: landing.height, viewport: viewport)
        trace("aim #\(memory.aims) \(landing.id) anchor \(anchor) viewport \(viewport)")
        var unanimated = Transaction()
        unanimated.disablesAnimations = true
        withTransaction(unanimated) {
            proxy.scrollTo(landing.id, anchor: UnitPoint(x: 0.5, y: anchor))
        }
    }

    /// Is the landed row where it belongs? Re-aim while it is not — its report
    /// missing (not realized yet), or no reading yet to judge by (an aim made
    /// before the scroll view could act on it moves nothing, and a geometry
    /// that never changes sends no reading): aim again, within the budget.
    private func check() {
        guard memory.holding, let landing = memory.landing else { return }
        let window = memory.window
        if window.isMeasured, let frame = model.placeMemory.frame(key, landing.id),
           LibraryPlace.isSettled(frame: frame, window: window, landing: landing) {
            return
        }
        aim()
    }

    private func scheduleChecks() {
        memory.episode &+= 1
        let episode = memory.episode
        memory.checks?.cancel()
        memory.checks = Task { @MainActor in
            var elapsed = Duration.zero
            for at in Self.holdChecks {
                try? await Task.sleep(for: at - elapsed)
                elapsed = at
                guard !Task.isCancelled, memory.episode == episode, memory.holding else { return }
                check()
            }
            guard memory.episode == episode else { return }
            finishHoldIfDone()
        }
    }

    /// The hold's checks are done: it ends — unless the return's re-ask is
    /// still in flight (its landing re-resolves and re-aims, then ends it).
    private func finishHoldIfDone() {
        guard !model.placeMemory.isRestoring(key) else { return }
        endHold()
    }

    private func endHold() {
        memory.holding = false
        memory.checks?.cancel()
        memory.checks = nil
    }

    // MARK: - The rest (her place, noted)

    private func armRest() {
        memory.lastMotion = .now
        guard memory.restWatch == nil else { return }
        memory.restWatch = Task { @MainActor in
            while !Task.isCancelled {
                let quiet = ContinuousClock.now - memory.lastMotion
                if quiet >= Self.restInterval {
                    memory.restWatch = nil
                    // Only a surface still on screen notes where it is.
                    guard memory.live else { return }
                    model.notePlace(placeKey: key)
                    trace("rest noted \(model.placeMemory.place(key)?.place.rows.first?.id ?? "nothing")")
                    return
                }
                try? await Task.sleep(for: Self.restInterval - quiet)
            }
        }
    }

    /// DEBUG: the decision log a pin can read (`LibraryPlaceTrace`).
    private func trace(_ line: @autoclosure () -> String) {
        #if DEBUG
        LibraryPlaceTrace.note(key, line())
        #endif
    }
}

#if DEBUG
/// **The return's decision log** (VX-823, DEBUG-only — the
/// `SidebarSectionTrace` shape): off unless a pin installs a `sink`; every
/// appear, landing decision, aim, re-ask and rest a pane's scroll makes, so a
/// red pin says WHICH step failed rather than only that the list sat at its
/// top (the walk's window-1 red was diagnosed by reading alone).
@MainActor
enum LibraryPlaceTrace {
    static var sink: ((String) -> Void)?

    static func note(_ key: String, _ line: @autoclosure () -> String) {
        guard let sink else { return }
        sink("[\(key)] " + line())
    }
}
#endif
