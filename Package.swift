// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "WorkspaceKit",
    platforms: [.macOS(.v14)],
    products: [.library(name: "WorkspaceKit", targets: ["WorkspaceKit"])],
    dependencies: [
        .package(url: "https://github.com/akhlaqahmad/docked-appcore.git", branch: "main")
    ],
    targets: [
        .target(name: "WorkspaceKit", dependencies: ["AppCore"])
    ]
)
