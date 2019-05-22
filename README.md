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
