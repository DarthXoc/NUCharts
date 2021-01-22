// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NUCharts",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "NUCharts",
            targets: ["NUCharts"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "NUCharts",
            dependencies: []),
        .testTarget(
            name: "NUChartsTests",
            dependencies: ["NUCharts"]),
    ]
)
