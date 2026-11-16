// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PockyFoundation",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "PockyFoundation", targets: ["PockyFoundation"])],
    targets: [
        .target(name: "PockyFoundation", resources: [.process("Resources")]),
        .testTarget(name: "PockyFoundationTests", dependencies: ["PockyFoundation"]),
    ]
)
