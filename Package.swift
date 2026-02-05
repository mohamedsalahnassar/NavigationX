// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "NavigationX",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "NavigationX",
            targets: ["NavigationX"]
        ),
        .library(
            name: "NavigationIntrospect",
            targets: ["NavigationIntrospect"]
        )
    ],
    targets: [
        .target(
            name: "NavigationIntrospect",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "NavigationX",
            dependencies: ["NavigationIntrospect"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "NavigationXTests",
            dependencies: ["NavigationX"]
        )
    ]

)
