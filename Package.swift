import PackageDescription

let package = Package(
	name: "MyFirstBackend",
	dependencies: [
		.Package(
		url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",
		majorVersion: 2
		)
	]
)
