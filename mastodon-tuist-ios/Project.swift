import ProjectDescription

let project = Project(
    name: "MastodonTuist",
    settings: .settings(configurations: [
        .debug(name: "Debug", xcconfig: "xcconfigs/Mastodon.xcconfig")
    ]),
    targets: [
        .target(
            name: "Mastodon",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.mastodon",
            infoPlist: "Mastodon/Info.plist",
            sources: .sourceFilesList(globs: [
                .glob("Mastodon/**/*.swift", excluding: ["Mastodon/Generated/**/*"]),
                .glob("Mastodon/**/*.lproj"),
                .glob("Mastodon/**/*.m")
            ]),
            resources: [
                "Mastodon/Resources/BoopSound.caf",
                "Mastodon/Supporting Files/**/*.lproj/LaunchScreen.storyboard",
                "Mastodon/Resources/Assets.xcassets",
                "Mastodon/Supporting Files/**/*.lproj/Main.storyboard",
                "MastodonIntent/**/*.lproj/Intents.stringsdict",
                "Mastodon/Resources/local-codes.json",
                "Mastodon/Resources/Preview Assets.xcassets",
                "Mastodon/Resources/**/*.lproj/InfoPlist.strings",
                "Mastodon/Supporting Files/Settings.bundle",
            ],
            entitlements: "Mastodon/Mastodon.entitlements",
            dependencies: [
                .external(name: "MastodonSDKDynamic"),
                .external(name: "MastoParse"),
                .external(name: "Bodega"),
                .external(name: "MBProgressHUD"),
                .external(name: "Kanna"),
                .sdk(name: "AuthenticationServices", type: .framework),
                .sdk(name: "VisionKit", type: .framework),
            ],
            settings: .settings(configurations: [
                .debug(name: "Debug", xcconfig: "xcconfigs/Mastodon-Target.xcconfig")
            ]))
    ])
