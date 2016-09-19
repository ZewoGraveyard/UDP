import PackageDescription

let package = Package(
    name: "UDP",
    dependencies: [
        .Package(url: "https://github.com/Zewo/POSIX.git", majorVersion: 0, minor: 13),
        .Package(url: "https://github.com/Zewo/Venice.git", majorVersion: 0, minor: 13),
        .Package(url: "https://github.com/Zewo/IP.git", majorVersion: 0, minor: 13),
    ]
)
