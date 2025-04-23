// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "Database",
  platforms: [.iOS(.v18)],
  products: [
    .library(
      name: "Database",
      targets: ["Database"]
    )
  ],
  targets: [
    .target(
      name: "Database",
      dependencies: [
        "GRDB"
      ]
    ),
    .binaryTarget(
      name: "GRDB",
      path: "../Generated/GRDB.xcframework" // Path relative to the Package.swift file
    ),
  ]
)
