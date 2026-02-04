// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PARAFoundation",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PARAFoundation",
            targets: ["PARAFoundation"]
        )
    ],
    targets: [
        .target(
            name: "PARAFoundation"
        ),
        .testTarget(
            name: "PARAFoundationTests",
            dependencies: ["PARAFoundation"]
        )
    ]
)
