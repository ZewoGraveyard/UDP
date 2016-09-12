import PackageDescription

let package = Package(
    name: "UDP",
    dependencies: [
        .Package(url: "https://github.com/Zewo/POSIX.git", majorVersion: 0, minor: 12),
        .Package(url: "https://github.com/VeniceX/Venice.git", majorVersion: 0, minor: 12),
        .Package(url: "https://github.com/VeniceX/IP.git", majorVersion: 0, minor: 12)
    ]
)
