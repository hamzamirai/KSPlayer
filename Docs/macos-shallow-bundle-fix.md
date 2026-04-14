# macOS Shallow Bundle Fix for FFmpegKit Frameworks

## Problem

Xcode 26 strictly validates that macOS frameworks use a **versioned (deep) bundle structure**. FFmpegKit ships its macOS xcframework slices as **shallow (iOS-style) bundles**, causing 24+ build errors:

```
Framework .../Libavcodec.framework contains Info.plist,
expected Versions/Current/Resources/Info.plist since the
platform does not use shallow bundles
```

This affects all FFmpegKit binary frameworks on macOS:
- Libavcodec, Libavdevice, Libavfilter, Libavformat, Libavutil, Libswresample, Libswscale
- gmp, gnutls, hogweed, nettle, lcms2
- libass, libbluray, libdav1d, libfontconfig, libfreetype, libfribidi
- libharfbuzz, libmpv, libplacebo, libshaderc_combined, libsmbclient, libsrt, libzvbi

## Root Cause

FFmpegKit's macOS framework slices use a flat/shallow structure:

```
MyFramework.framework/
  Info.plist          <-- wrong location for macOS
  MyFramework
  Headers/
  Modules/
```

macOS requires a versioned (deep) structure:

```
MyFramework.framework/
  Versions/
    A/
      MyFramework
      Headers/
      Modules/
      Resources/
        Info.plist    <-- correct location
    Current -> A
  MyFramework -> Versions/Current/MyFramework
  Headers -> Versions/Current/Headers
  Modules -> Versions/Current/Modules
  Resources -> Versions/Current/Resources
```

## Fix Applied

All 25 macOS framework slices in `/Sources/*/macos-arm64_x86_64/*.framework/` were converted from shallow to versioned structure.

### Conversion Script

To re-apply this fix (e.g. after pulling upstream changes from FFmpegKit):

```bash
cd /Users/mirai/MiraiDevsWork/iOSProjects/FFmpegKit

find Sources -path "*/macos-arm64_x86_64/*.framework" -type d | while read framework; do
  [ -d "$framework/Versions" ] && continue
  plist="$framework/Info.plist"
  [ -f "$plist" ] || continue
  name=$(basename "$framework" .framework)
  echo "Converting: $name"

  mkdir -p "$framework/Versions/A/Resources"
  mv "$plist" "$framework/Versions/A/Resources/Info.plist"
  [ -f "$framework/$name" ] && mv "$framework/$name" "$framework/Versions/A/$name"
  [ -d "$framework/Headers" ] && mv "$framework/Headers" "$framework/Versions/A/Headers"
  [ -d "$framework/Modules" ] && mv "$framework/Modules" "$framework/Versions/A/Modules"

  (cd "$framework" && \
    ln -sf A Versions/Current && \
    ln -sf "Versions/Current/$name" "$name" 2>/dev/null && \
    ln -sf "Versions/Current/Headers" Headers 2>/dev/null && \
    ln -sf "Versions/Current/Modules" Modules 2>/dev/null && \
    ln -sf "Versions/Current/Resources" Resources 2>/dev/null)
done
```

## Local Package Setup

### Dependency Chain

```
SpatialIStream (Xcode project)
  └── KSPlayer (local: /Users/mirai/MiraiDevsWork/iOSProjects/KSPlayer)
        └── FFmpegKit (local: /Users/mirai/MiraiDevsWork/iOSProjects/FFmpegKit)
```

### KSPlayer Package.swift Change

The remote FFmpegKit dependency was replaced with a local path:

```swift
// Before (remote):
.package(url: "https://github.com/kingslay/FFmpegKit.git", from: "6.1.3"),

// After (local):
.package(path: "../FFmpegKit"),
```

### Xcode Project Change

The remote KSPlayer SPM dependency was replaced with a local package reference pointing to `/Users/mirai/MiraiDevsWork/iOSProjects/KSPlayer`.

## Notes

- iOS, tvOS, and visionOS framework slices are unaffected — they correctly use shallow bundles
- Only the `macos-arm64_x86_64` slices needed conversion
- The existing build phase script "[CP] Convert Shallow Frameworks to Versioned (macOS)" in the Xcode project was an earlier workaround attempt that didn't work reliably because Xcode 26's Validate step runs independently of build phase scripts
- Upstream fix: https://github.com/kingslay/FFmpegKit/issues — consider filing an issue
