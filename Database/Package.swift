// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "Database",
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
