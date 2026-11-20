// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "CheckReadmeValues",
    platforms: [.macOS(.v14)],
    dependencies: [.package(name: "PockyFoundation", path: "../..")],
    targets: [
        .executableTarget(
            name: "CheckReadmeValues",
            dependencies: [.product(name: "PockyFoundation", package: "PockyFoundation")]
        ),
    ]
)
