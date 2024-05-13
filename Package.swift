// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Debugger",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "Debugger",
            targets: ["Debugger"]
        ),
    ],
    targets: [
        .target(
            name: "Debugger"
        ),
        .testTarget(
            name: "DebuggerTests",
            dependencies: ["Debugger"]
        ),
    ]
)
