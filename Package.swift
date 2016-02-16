import PackageDescription

let package = Package(
    name: "UDP",
    dependencies: [
        .Package(url: "https://github.com/Zewo/IP.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/Zewo/System.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/Zewo/Data.git", majorVersion: 0, minor: 2),
        .Package(url: "https://github.com/Zewo/CLibvenice.git", majorVersion: 0, minor: 2)
    ]
)