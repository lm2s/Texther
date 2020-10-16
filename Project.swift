//  Based on the Tuist uFeatures example project (https://github.com/tuist/microfeatures-example)

import ProjectDescription
import ProjectDescriptionHelpers

func targets() -> [Target] {
    var targets: [Target] = []
    targets += Target.makeAppTargets(name: "Texther", displayName: "Texther", dependencies: ["uHome"], testDependencies: [])
    targets += Target.makeFrameworkTargets(name: "uCore", externalDependencies: [.package(product: "ComposableArchitecture")])
    targets += Target.makeFrameworkTargets(name: "uNetwork", dependencies: ["uCore"])
    targets += Target.makeFrameworkTargets(name: "uHome", dependencies: ["uCore", "uNetwork"])
    return targets
}

let project = Project(name: "Texther",
                      packages: [
                        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .branch("main"))
                      ],
                      settings: Settings(),
                      targets: targets())
