import AppKit
import AppCore

/// Lightweight global hotkey monitor using `NSEvent` global/local monitors.
/// For richer hotkey UX (allows reserved combos) swap in `Carbon.RegisterEventHotKey`.
@MainActor
public final class GlobalHotkeyMonitor {
    public typealias Handler = (KeyShortcut) -> Void

    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var bindings: [KeyShortcut: Handler] = [:]

    public init() {}

    public func register(_ shortcut: KeyShortcut, handler: @escaping Handler) {
        bindings[shortcut] = handler
        ensureStarted()
    }

    public func unregister(_ shortcut: KeyShortcut) {
        bindings.removeValue(forKey: shortcut)
        if bindings.isEmpty { stop() }
    }

    private func ensureStarted() {
        guard globalMonitor == nil else { return }
        let mask: NSEvent.EventTypeMask = [.keyDown]
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: mask) { [weak self] event in
            self?.dispatch(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: mask) { [weak self] event in
            self?.dispatch(event)
            return event
        }
    }

    public func stop() {
        if let m = globalMonitor { NSEvent.removeMonitor(m) }
        if let m = localMonitor { NSEvent.removeMonitor(m) }
        globalMonitor = nil
        localMonitor = nil
    }

    private func dispatch(_ event: NSEvent) {
        let keyCode = event.keyCode
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask).rawValue
        for (shortcut, handler) in bindings {
            if shortcut.keyCode == keyCode && shortcut.modifiersRaw == modifiers {
                handler(shortcut)
            }
        }
    }
}
