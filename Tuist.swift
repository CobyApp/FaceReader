import ProjectDescription

let tuist = Tuist(
    project: .tuist(
        compatibleXcodeVersions: .all,
        swiftVersion: Version(5, 10, 0)
    )
)
