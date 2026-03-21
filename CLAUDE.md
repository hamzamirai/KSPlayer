# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test

```bash
# Build (macOS)
swift build

# Build for iOS simulator
swift build --sdk `xcrun -sdk iphonesimulator -show-sdk-path` -Xswiftc -target -Xswiftc arm64-apple-ios17.0-simulator

# Build for tvOS simulator
swift build --sdk `xcrun -sdk appletvsimulator -show-sdk-path` -Xswiftc -target -Xswiftc arm64-apple-tvos17.0-simulator

# Run tests
swift test -v
```

**FFmpegKit dependency** is a local package at `../FFmpegKit` — the sibling directory must be checked out before building.

**macOS frameworks** ship as shallow bundles (iOS-style). If FFmpegKit is updated, run the conversion script documented in `Docs/macos-shallow-bundle-fix.md` to revert to versioned (deep) bundles required by Xcode 26+.

## Architecture

### Two-Player Design
KSPlayer provides two interchangeable backends behind the `MediaPlayerProtocol`:

- **KSAVPlayer** — thin AVFoundation wrapper; used first for broad format support with low overhead
- **KSMEPlayer** — FFmpeg-based decoder; used as fallback when KSAVPlayer fails, or configured as primary via `KSOptions.firstPlayerType`

`KSPlayerLayer` orchestrates the fallback automatically: if KSAVPlayer encounters a playback error it instantiates `KSOptions.secondPlayerType` (default: KSMEPlayer) transparently.

### Layer Hierarchy
```
KSVideoPlayerView (SwiftUI)
  └─ KSVideoPlayer (UIViewRepresentable / NSViewRepresentable)
       └─ KSPlayerLayer (@MainActor, state machine)
            └─ MediaPlayerProtocol (KSAVPlayer or KSMEPlayer)
                  └─ VideoPlayerView (UIKit/AppKit UI — controls, gestures, overlays)
```

- **KSPlayerLayer** — playlist management, seek, buffering state, remote control registration, PiP
- **KSVideoPlayer.Coordinator** — `@Observable` bridge between SwiftUI bindings and the UIKit layer
- **VideoPlayerView** / platform variants (IOSVideoPlayerView, MacVideoPlayerView) — all gesture and overlay UI

### Source Layout
| Folder | Responsibility |
|--------|---------------|
| `AVPlayer/` | KSAVPlayer, KSPlayerLayer, KSVideoPlayer, KSOptions, MediaPlayerProtocol |
| `MEPlayer/` | FFmpeg decoding pipeline: MEPlayerItem, audio engines (AudioUnitPlayer, AudioGraphPlayer, AudioEnginePlayer), Model, ThumbnailController |
| `Metal/` | GPU rendering — MetalRender, MetalPlayView, Shaders.metal |
| `Video/` | UIKit player UI — VideoPlayerView and platform subclasses, SeekView, BrightnessVolume |
| `SwiftUI/` | KSVideoPlayerView, KSSlider, subtitle overlays |
| `Subtitle/` | Subtitle parsing (KSParseProtocol), KSSubtitle, SubtitleDataSource |
| `Core/` | UXKit (UIView↔NSView aliases), platform extensions, Utility |

### Platform Abstraction
`Core/UXKit.swift` provides `UXView`, `UXColor`, `UXImage`, etc. aliases so the same code compiles on iOS, macOS, tvOS, and visionOS. Use `UXKit` types in shared code; only reach for `#if os(macOS)` for genuinely platform-specific behavior.

## Swift 6 Concurrency Rules

The package compiles in **Swift 6 strict concurrency mode** (`swiftLanguageModes: [.v6]`). All player classes and protocols are `@MainActor`.

- **All playback operations must be called from the main thread.** `KSAVPlayer`, `KSMEPlayer`, `KSPlayerLayer`, and `MediaPlayerProtocol` are all `@MainActor`.
- **Background work** uses an explicit serial `DispatchQueue` (e.g. `audioPrepQueue` in KSMEPlayer for audio engine rebuilds). Never block the main thread with FFmpeg I/O.
- **Closures crossing actor boundaries** must be `@Sendable`.
- **`@preconcurrency`** is used on Apple framework protocol conformances that predate concurrency (e.g. `AVPictureInPictureControllerDelegate`).
- **`MainActor.assumeIsolated {}`** is used inside deinit/shutdown paths where the compiler cannot prove main-actor isolation but the call site guarantees it.
- Avoid `nonisolated(unsafe)` unless there is no other option.

## Key Configuration: KSOptions

`KSOptions` is the central configuration object passed at player creation. Important properties:

- `firstPlayerType` / `secondPlayerType` — control which backend is tried first/on fallback
- `preferredForwardBufferDuration` / `maxBufferDuration` — buffering window
- `isSecondOpen` — fast-start ("instant open") mode
- `isAccurateSeek` — frame-accurate seeking (slower)
- `hardwareDecode` / `asynchronousDecompression` — FFmpeg HW acceleration
- `videoFilters` / `audioFilters` — FFmpeg filter strings
- `avOptions` / `formatContextOptions` / `decoderOptions` — raw FFmpeg dicts

`KSOptions` is designed to be subclassed — apps override `preferredForwardBufferDuration(isLive:)`, `videoFrameMaxCount`, `audioFrameMaxCount`, etc. to tune per-stream buffering.

## Demo Projects

- `Demo/SwiftUI/` — cross-platform SwiftUI demo (iOS, macOS, tvOS)
- `Demo/demo-iOS/`, `demo-macOS/`, `demo-tvOS/` — UIKit/AppKit demos

The SwiftUI demo's `KSOptions` defaults live in `Demo/SwiftUI/Shared/Defaults.swift`.
