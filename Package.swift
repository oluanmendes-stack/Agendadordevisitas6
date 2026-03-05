// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ImoveisApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ImoveisApp",
            targets: ["ImoveisApp"]
        )
    ],
    targets: [
        .target(
            name: "ImoveisApp",
            path: "ImoveisApp",
            exclude: ["Info.plist", "ImoveisApp.entitlements"],
            resources: [
                .process("Assets.xcassets")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "ImoveisAppTests",
            dependencies: ["ImoveisApp"],
            path: "ImoveisAppTests"
        )
    ]
)
