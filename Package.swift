import PackageDescription

let package = Package(
    name: "UDP",
    dependencies: [
        .Package(url: "https://github.com/segabor/IP.git", "0.9.1")
    ]
)
