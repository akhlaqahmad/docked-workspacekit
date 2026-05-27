import Foundation
import ServiceManagement

public enum LoginItem {
    /// Register / unregister the app to launch at login using the modern
    /// `SMAppService` API (macOS 13+).
    public static func setLaunchAtLogin(_ enabled: Bool) throws {
        let service = SMAppService.mainApp
        if enabled {
            if service.status != .enabled {
                try service.register()
            }
        } else {
            if service.status == .enabled {
                try service.unregister()
            }
        }
    }

    public static var isLaunchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }
}
