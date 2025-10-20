// swift-tools-version: 6.2
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        productTypes: [
            "Atomics": .framework,
            "Alamofire": .framework,
            "SDWebImage": .framework,
            "TOCropViewController": .framework,
            "XLPagerTabStrip": .framework,
            "NIOPosix": .framework,
            "MastodonSDKDynamic": .framework,
            "MastoParse": .framework,
            "Bodega": .framework,
            "MBProgressHUD": .framework,
            "Kanna": .framework,
            "CNIOAtomics": .framework,
            "CNIODarwin": .framework,
            "CNIOLinux": .framework,
            "CNIOWASI": .framework,
            "CNIOWindows": .framework,
            "DequeModule": .framework,
            "InternalCollectionsUtilities": .framework,
            "LRUCache": .framework,
            "NIOConcurrencyHelpers": .framework,
            "NIOCore": .framework,
            "SwiftSoup": .framework,
            "_AtomicsShims": .framework,
            "_NIOBase64": .framework,
            "_NIODataStructures": .framework,
        ], baseSettings: .settings(configurations: [.debug(name: "Debug")]))
#endif

let package = Package(
    name: "Mastodon",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.10.2"),
        .package(url: "https://github.com/Alamofire/AlamofireImage.git", exact: "4.3.0"),
        .package(url: "https://github.com/mergesort/Bodega.git", exact: "2.1.3"),
        .package(url: "https://github.com/will-lumley/FaviconFinder.git", exact: "4.5.0"),
        .package(url: "https://github.com/Flipboard/FLAnimatedImage.git", exact: "1.0.17"),
        .package(url: "https://github.com/cezheng/Fuzi.git", exact: "3.1.3"),
        .package(url: "https://github.com/nicklockwood/FXPageControl.git", exact: "1.6.0"),
        .package(url: "https://github.com/tid-kijyun/Kanna.git", exact: "5.3.0"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", exact: "4.2.2"),
        .package(url: "https://github.com/Bearologics/LightChart.git", branch: "master"),
        .package(url: "https://github.com/nicklockwood/LRUCache.git", exact: "1.1.2"),
        .package(url: "https://github.com/mastodon/MastoParse.git", branch: "main"),
        .package(url: "https://github.com/jdg/MBProgressHUD.git", exact: "1.2.0"),
        .package(url: "https://github.com/mastodon/MetaTextKit.git", branch: "2.2.5-xcode16"),
        .package(
            url: "https://github.com/NextLevel/NextLevelSessionExporter.git",
            revision: "1fd5ad50fa415b4b197e9b05c0cdd3cc2ee6731e"),
        .package(url: "https://github.com/kean/Nuke.git", exact: "10.11.2"),
        .package(url: "https://github.com/uias/Pageboy", exact: "3.7.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImage.git", exact: "5.21.2"),
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", exact: "0.15.4"),
        .package(url: "https://github.com/eneko/Stripes.git", exact: "0.2.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", exact: "1.3.0"),
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.2.1"),
        .package(url: "https://github.com/apple/swift-nio.git", exact: "2.86.0"),
        .package(url: "https://github.com/apple/swift-system.git", exact: "1.6.3"),
        .package(url: "https://github.com/swiftlang/swift-toolchain-sqlite", exact: "1.0.4"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", exact: "2.11.1"),
        .package(url: "https://github.com/TwidereProject/TabBarPager.git", exact: "0.1.2"),
        .package(url: "https://github.com/uias/Tabman", exact: "2.13.0"),
        .package(url: "https://github.com/TimOliver/TOCropViewController.git", exact: "2.7.4"),
        .package(
            url: "https://github.com/woxtu/UIHostingConfigurationBackport.git", exact: "0.1.0"),
        //         .package(url: "https://github.com/MainasuK/UITextView-Placeholder.git", exact: "1.4.2"),
        .package(url: "https://github.com/xmartlabs/XLPagerTabStrip.git", exact: "9.1.0"),
        .package(path: "../MastodonSDK"),
    ]
)
