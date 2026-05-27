import AppKit
import AppCore

public enum IconResolver {
    /// Cache for resolved icons. Keyed by stable string (file path or override
    /// path). Capped at 256 entries; NSCache evicts under memory pressure.
    /// NSCache is thread-safe.
    private static let cache: NSCache<NSString, NSImage> = {
        let c = NSCache<NSString, NSImage>()
        c.countLimit = 256
        c.name = "my.docked.IconResolver"
        return c
    }()

    /// Resolve an `NSImage` for the given `DockItem`, honoring user icon overrides
    /// and falling back to LaunchServices / NSWorkspace.
    ///
    /// Cached by absolute path for the lifetime of the process. Call
    /// `invalidate(_:)` if the underlying file's icon has changed.
    @MainActor
    public static func resolve(_ item: DockItem) -> NSImage? {
        if let key = cacheKey(for: item),
           let cached = cache.object(forKey: key as NSString) {
            return cached
        }

        let image: NSImage? = {
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
                case .clock:     return NSImage(systemSymbolName: "clock", accessibilityDescription: nil)
                case .ipAddress: return NSImage(systemSymbolName: "network", accessibilityDescription: nil)
                case .finder:    return NSWorkspace.shared.icon(forFile: "/System/Library/CoreServices/Finder.app")
                case .trash:     return NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
                case .battery:   return NSImage(systemSymbolName: "battery.100", accessibilityDescription: nil)
                case .calendar:  return NSImage(systemSymbolName: "calendar", accessibilityDescription: nil)
                }
            case .separator, .spacer:
                return nil
            }
        }()

        if let key = cacheKey(for: item), let image {
            cache.setObject(image, forKey: key as NSString)
        }
        return image
    }

    /// Drop the cached icon for an item (e.g., after the user picks a new override).
    public static func invalidate(_ item: DockItem) {
        if let key = cacheKey(for: item) {
            cache.removeObject(forKey: key as NSString)
        }
    }

    /// Clear all cached icons. Useful in tests or after a global theme change.
    public static func invalidateAll() {
        cache.removeAllObjects()
    }

    // MARK: - Internals

    /// Stable cache key for an item. Returns nil for items with no icon
    /// (separator, spacer) or items whose icon is purely symbol-based (widgets).
    private static func cacheKey(for item: DockItem) -> String? {
        switch item {
        case .app(let app):
            return app.iconOverridePath ?? app.appURL.path
        case .folder(let folder):
            return folder.path.path
        case .file(let file):
            return file.path.path
        case .url(let url):
            return url.iconOverridePath
        case .widget, .separator, .spacer:
            // Symbol-rendered or no-icon — no benefit to caching here.
            return nil
        }
    }
}
