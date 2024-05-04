// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SerializedNavPath",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "SerializedNavPath",
            targets: ["SerializedNavPath"]),
    ],
    targets: [
        .target(name: "SerializedNavPath")
    ]
)
