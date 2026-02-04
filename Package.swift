// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppPad",
    platforms: [
        .macOS(.v14) // Target macOS 14+ (Sonoma/Sequoia implied context, though user said macOS 26, we target latest stable for now or v15 if allowed)
    ],
    products: [
        .executable(name: "AppPad", targets: ["AppPad"]),
    ],
    targets: [
        .executableTarget(
            name: "AppPad",
            path: "Sources/AppPad",
            exclude: [],
            sources: nil, // Automatically picks up .swift files
            resources: [],
            linkerSettings: [
                .linkedFramework("AppKit")
            ]
        )
    ]
)
