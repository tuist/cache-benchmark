# Contributing

- File an issue to report a bug or feature request
- Translate the project in our [Crowdin](https://crowdin.com/project/mastodon-for-ios) project
- Make the Pull Request to contribute

## Bug Report
File an issue about the bug or feature request. Make sure you are installing the latest version of the app from TestFlight or App Store.

## Translation
[![Crowdin](https://badges.crowdin.net/mastodon-for-ios/localized.svg)](https://crowdin.com/project/mastodon-for-ios)

The translation will update regularly. Please request the language if it is not listed via an issue.

To add new localized strings:

Basic:
- Edit `Localization/app.json` to add new strings in an appropriate section of the JSON.
- Edit `MastodonSDK/Sources/MastodonLocalizations/Resources/Base.lproj/Localizable.strings` to add the same strings as in `app.json`. Take care to follow to formatting pattern of existing examples.
- Run `swiftgen` inside the project directory to generate the typed string resources.
- Use the new typed strings by importing `MastodonLocalization` and using the `L10n` struct.
  
Plurals:
- Add appropriate entry to `MastodonSDK/Sources/MastodonLocalizations/Resources/Base.lproj/Localizable.stringsdict` (feel free to copy a similar example and then edit it).
- Run `swiftgen` inside the project directory to generate the typed string resources.
- Use the new plural format strings by importing `MastodonLocalization` and using the `L10n` struct.

## Pull Request

You can create a pull request directly with small block code changes for bugfix or feature implementations. Before making a pull request with hundred lines of changes to this repository, please first discuss the change you wish to make via an issue. 

Also, there are lots of existing feature request issues that could be a good-first-issue discussing place.

Follow the git-flow pattern to make your pull request.

1. Ensure you have started a new branch based on the `develop` branch.
2. Write your changes and test them on **iPad and iPhone**.
3. Merge the `develop` branch into your branch then make a Pull Request. Please merge the branch and resolve any conflicts if `develop` updates. **Do not force push your commits.**
4. Make sure the permission for your fork is open to the reviewer. Code style fix, conflict resolution, and other changes may be committed by the reviewer directly.
5. Request a code review and wait for approval. The PR will be merged when it is approved.

## Documentation
The documentation for this app is listed under the [Documentation](../Documentation/) folder. We are also welcoming contributions for documentation.
