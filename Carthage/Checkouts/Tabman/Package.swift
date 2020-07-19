// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Tabman",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "Tabman",
            targets: ["Tabman"])
    ],
    dependencies: [
        .package(url: "https://github.com/uias/Pageboy", from: "3.6.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Tabman",
            dependencies: ["Pageboy"],
            path: ".",
            exclude: ["Sources/Tabman/Tabman.h", "Sources/Tabman/Info.plist"],
            sources: ["Sources/Tabman"]),
        .testTarget(
            name: "TabmanTests",
            dependencies: ["Tabman"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
