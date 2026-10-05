import SwiftUI

@main
struct LuminaCameraApp: App {

    @StateObject private var permissionManager = PermissionManager.shared
    @StateObject private var settingsManager = SettingsManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if permissionManager.cameraPermissionGranted {
                    MainCameraView()
                } else {
                    PermissionView()
                        .environmentObject(permissionManager)
                }
            }
            .preferredColorScheme(.dark)
            .task {
                await permissionManager.requestAllPermissions()
            }
        }
    }
}
