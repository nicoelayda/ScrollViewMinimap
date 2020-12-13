// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ScrollViewMinimap",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "ScrollViewMinimap",
            targets: ["ScrollViewMinimap"]),
    ],
    targets: [
        .target(
            name: "ScrollViewMinimap"),
        .testTarget(
            name: "ScrollViewMinimapTests",
            dependencies: ["ScrollViewMinimap"]),
    ]
)
