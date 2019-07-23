# backit-ios

The Backit full line iOS application

## Convert SVG to PDP

First download Cairo via `brew`.

```
brew install python3 cairo pango gdk-pixbuf libffi
pip3 install cairosvg
```

Convert

```
cairosvg icon.svg -o icon.pdf
```

## Record a Video Session

Start recording with:

```
xcrun simctl io booted recordVideo signin.mp4
```

Press Ctrl+C to stop the video.

## TODO

Load a different `AppDelegate` at test time so that network calls, etc. are not incurred at test time.

# Building the Project

Install dependencies
```
$ brew install carthage xcodegen
```

Dependencies that are not in source control and should be placed in `Backit/SDK/`:
- NewRelic v6.7.0

Build iOS dependencies using Carthage
```
$ carthage update --platform iOS
```

Create the project files
```
$ xcodegen
$ pod install
$ open Backit.xcworkspace
```

## Configuration

`xcodegen` does not perform operations which must be done in order for the project to build. Therefore, it is necessary to perform these operations manually:

1. Fix embedded frameworks
- Tap the `Backit` project in Xcode
- Build Phases
- Embed Frameworks Group
- (x) Copy only when installing

2. Disable Mixpanel
- Find `MixpanelAnalyticsListener.swift`
- Open Inspector pane
- Remove from Backit target membership

3. Select a Team (not necessary except for build machine)
- Tap the `Backit` project
- General
- Select a Team to build the project as
