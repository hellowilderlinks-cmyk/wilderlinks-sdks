// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "WilderlinksSDK",
  platforms: [.iOS(.v13), .macOS(.v12)],
  products: [
    .library(name: "WilderlinksSDK", targets: ["WilderlinksSDK"]),
  ],
  targets: [
    .target(name: "WilderlinksSDK"),
    .testTarget(name: "WilderlinksSDKTests", dependencies: ["WilderlinksSDK"]),
  ]
)
