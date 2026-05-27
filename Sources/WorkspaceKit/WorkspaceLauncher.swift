import AppKit
import AppCore

public enum WorkspaceLauncher {
    @MainActor
    public static func open(_ item: DockItem) {
        switch item {
        case .app(let app):
            let config = NSWorkspace.OpenConfiguration()
            config.activates = true
            NSWorkspace.shared.openApplication(at: app.appURL, configuration: config) { _, _ in }
        case .folder(let folder):
            NSWorkspace.shared.open(folder.path)
        case .file(let file):
            NSWorkspace.shared.open(file.path)
        case .url(let url):
            NSWorkspace.shared.open(url.url)
        case .widget, .separator, .spacer:
            break
        }
    }
}
