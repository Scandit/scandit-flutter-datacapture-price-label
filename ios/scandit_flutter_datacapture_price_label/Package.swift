// swift-tools-version: 5.9
import Foundation
import PackageDescription

// Read version from pubspec.yaml
func getVersion() -> String {
    let pubspecPath = Context.packageDirectory + "/../../pubspec.yaml"
    guard let content = try? String(contentsOfFile: pubspecPath, encoding: .utf8) else {
        fatalError("Could not read pubspec.yaml at \(pubspecPath)")
    }

    // Parse version line (format: "version: X.Y.Z")
    let lines = content.components(separatedBy: .newlines)
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("version:") {
            let versionString =
                trimmed
                .replacingOccurrences(of: "version:", with: "")
                .trimmingCharacters(in: .whitespaces)
            return versionString
        }
    }

    fatalError("Could not find version in pubspec.yaml at \(pubspecPath)")
}

let version = getVersion()
let frameworkName = "ScanditPriceLabel"
let localFrameworkRelPath = "Frameworks/\(frameworkName).xcframework"
// FileManager.fileExists does not work under SPM manifest sandbox (Xcode 16+).
// Use String(contentsOfFile:) instead — same approach as getVersion() above.
let xcframeworkInfoPath = Context.packageDirectory + "/" + localFrameworkRelPath + "/Info.plist"
let useLocalFramework = (try? String(contentsOfFile: xcframeworkInfoPath, encoding: .utf8)) != nil

var dependencies: [Package.Dependency] = []
var targetDeps: [Target.Dependency] = []
var targets: [Target] = []

if useLocalFramework {
    targets.append(
        .binaryTarget(name: frameworkName, path: localFrameworkRelPath)
    )
    targetDeps.append(.byName(name: frameworkName))
} else {
    dependencies.append(
        .package(url: "https://github.com/Scandit/datacapture-spm.git", exact: Version(stringLiteral: version))
    )
    targetDeps.append(.product(name: frameworkName, package: "datacapture-spm"))
}

targets.insert(
    .target(
        name: "scandit_flutter_datacapture_price_label",
        dependencies: targetDeps,
        path: "Sources/scandit_flutter_datacapture_price_label"
    ),
    at: 0
)

let package = Package(
    name: "scandit_flutter_datacapture_price_label",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "scandit-flutter-datacapture-price-label",
            targets: ["scandit_flutter_datacapture_price_label"]
        )
    ],
    dependencies: dependencies,
    targets: targets
)
