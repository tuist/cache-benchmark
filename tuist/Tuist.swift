import ProjectDescription

let config = Config(
    fullHandle: "tuist/tuist",
    url: "https://staging.tuist.dev",
    swiftVersion: .init("5.10"),
    generationOptions: .options(
        optionalAuthentication: true,
        disableSandbox: true,
    )
)
