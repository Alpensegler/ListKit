// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "ListKit",
    platforms: [.iOS(.v9), .macOS(.v10_15)],
    products: [.library(name: "ListKit", targets: ["ListKit"])],
    targets: [.target(name: "ListKit", path: "Sources")]
)
