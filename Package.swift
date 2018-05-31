// swift-tools-version:4.0
import PackageDescription

//let package = Package(
//    name: "TILApp",
//    dependencies: [
//        // 💧 A server-side Swift web framework.
//        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
//
//        // 🔵 Swift ORM (queries, models, relations, etc) built on SQLite 3.
//        .package(url: "https://github.com/vapor/fluent-sqlite.git", from: "3.0.0-rc.2")
//    ],
//    targets: [
//        .target(name: "App", dependencies: ["FluentSQLite", "Vapor"]),
//        .target(name: "Run", dependencies: ["App"]),
//        .testTarget(name: "AppTests", dependencies: ["App"])
//    ]
//)

//The above is replaced with the following for postgresql...

let package = Package(name: "TILApp", dependencies: [
    .package(url: "https://github.com/vapor/vapor.git",
    from: "3.0.0-rc"),
    // 1. Specify FluentPostSQL as a package dependency.
    .package(url: "https://github.com/vapor/fluent-postgresql.git",
    from: "1.0.0-rc"),
    ],
    targets: [
    // 2. Specify that the App target depends on FluentPostgreSQL to ensure it links correctly.
    .target(name: "App", dependencies: ["FluentPostgreSQL", "Vapor"]),
    .target(name: "Run", dependencies: ["App"]),
    .testTarget(name: "AppTests", dependencies: ["App"]),
    ]
)

//The above is replaced with the following for MySQL...

//let package = Package(name: "TILApp", dependencies: [
//    .package(url: "https://github.com/vapor/vapor.git",
//    from: "3.0.0-rc"),
//    // 1. Specify FluentMySQL as a package dependency.
//    .package(url: "https://github.com/vapor/fluent-mysql.git",
//    from: "3.0.0-rc"),
//    ],
//    targets: [
//    // 2. Specify that the App target depends on FluentMySQL to ensure it links correctly.
//    .target(name: "App", dependencies: ["FluentMySQL", "Vapor"]),
//    .target(name: "Run", dependencies: ["App"]),
//    .testTarget(name: "AppTests", dependencies: ["App"]),
//    ]
//)
