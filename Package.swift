// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Reactive",
    products: [
        .library(
            name: "Reactive",
            targets: ["Reactive"])
        ],
    targets: [
        .target(
            name: "Reactive",
            dependencies: []
            ),
        .testTarget(
            name: "ReactiveTests",
            dependencies: ["Reactive"])
        ]
)
