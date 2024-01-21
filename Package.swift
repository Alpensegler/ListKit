// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ListKit",
    platforms: [.iOS(.v11), .macOS(.v10_11)],
    products: [.library(name: "ListKit", targets: ["ListKit"])],
    targets: [
        .target(name: "ListKit", path: "Sources"),
        .testTarget(name: "ListKitTests", dependencies: ["ListKit"])
    ]
)
