// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "tv_textfield",
  platforms: [
    .iOS("13.0"),
    .tvOS("13.0"),
  ],
  products: [
    .library(name: "tv-textfield", targets: ["tv_textfield"]),
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework"),
  ],
  targets: [
    .target(
      name: "tv_textfield",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
      ],
      resources: [
        .process("Resources"),
      ]
    ),
  ]
)
