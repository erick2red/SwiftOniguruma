// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftOniguruma",
    platforms: [
        .macOS(.v11),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(name: "SwiftOniguruma", targets: ["SwiftOniguruma"]),
    ],
    targets: [
        .systemLibrary(name: "coniguruma", pkgConfig: "oniguruma", providers: [.brew(["oniguruma"])]),
        .target(name: "SwiftOniguruma", dependencies: ["coniguruma"]),
        .testTarget(name: "SwiftOnigurumaTests", dependencies: ["SwiftOniguruma"]),
    ]
)
