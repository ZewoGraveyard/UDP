import PackageDescription

let package = Package(
    name: "UDP",
    dependencies: [
        .Package(url: "https://github.com/VeniceX/IP.git", majorVersion: 0, minor: 7),
    ]
)
