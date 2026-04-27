// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OutTravelCore",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "OutTravelCore", targets: ["OutTravelCore"])
    ],
    targets: [
        .target(
            name: "OutTravelCore",
            path: "ios/OutTravelCore"
        ),
        .testTarget(
            name: "OutTravelCoreTests",
            dependencies: ["OutTravelCore"],
            path: "ios/OutTravelCoreTests"
        )
    ]
)
