import AppKit
import AppCore

public enum IconResolver {
    /// Resolve an `NSImage` for the given `DockItem`, honoring user icon overrides
    /// and falling back to LaunchServices / NSWorkspace.
    @MainActor
    public static func resolve(_ item: DockItem) -> NSImage? {
        switch item {
        case .app(let app):
            if let path = app.iconOverridePath, let image = NSImage(contentsOfFile: path) { return image }
            return NSWorkspace.shared.icon(forFile: app.appURL.path)
        case .folder(let folder):
            return NSWorkspace.shared.icon(forFile: folder.path.path)
        case .file(let file):
            return NSWorkspace.shared.icon(forFile: file.path.path)
        case .url(let url):
            if let path = url.iconOverridePath, let image = NSImage(contentsOfFile: path) { return image }
            return NSImage(systemSymbolName: "safari", accessibilityDescription: nil)
        case .widget(let widget):
            switch widget.kind {
            case .clock: return NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
            case .ipAddress: return NSImage(systemSymbolName: "network", accessibilityDescription: nil)
            case .finder: return NSWorkspace.shared.icon(forFile: "/System/Library/CoreServices/Finder.app")
            case .trash: return NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
            case .battery: return NSImage(systemSymbolName: "battery.100", accessibilityDescription: nil)
            case .calendar: return NSImage(systemSymbolName: "calendar", accessibilityDescription: nil)
            }
        case .separator, .spacer:
            return nil
        }
    }
}
