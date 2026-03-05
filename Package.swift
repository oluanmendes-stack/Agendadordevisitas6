import PackageDescription

let package = Package(
    name: "AgendadorDeVisitas",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .executable(name: "AgendadorDeVisitas", targets: ["AgendadorDeVisitas"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "AgendadorDeVisitas",
            dependencies: [],
            path: "Sources/AgendadorDeVisitas"
        )
    ]
)