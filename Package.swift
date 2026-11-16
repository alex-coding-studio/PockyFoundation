// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PockyFoundation",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "PockyFoundation", targets: ["PockyFoundation"])],
    targets: [
        .target(name: "PockyFoundation"),
        .testTarget(name: "PockyFoundationTests", dependencies: ["PockyFoundation"]),
    ]
)
