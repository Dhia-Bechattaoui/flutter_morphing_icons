# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

_No unreleased changes yet._

## [0.2.0] - 2025-11-09

### Added
- README preview section featuring animation and interactive GIF demos ahead of the feature list.

### Changed
- Slide animation defaults now use fractional offsets and are clipped to the widget’s bounds for consistent, container-scoped motion.

### Fixed
- Fixed slide transition to work correctly when combined with fade, scale, or rotate effects using proper `SlideTransition` widget.
- Improved custom animation implementation using `AnimatedSwitcher` with stacked transition widgets for reliable multi-effect animations.

## [0.1.0] - 2025-11-09

### Added
- Funding metadata and extended platform declarations for Android, iOS, Web, Windows, macOS, Linux, and WASM-compatible Flutter targets.
- Parameterized custom animation support (fade/scale/slide/rotate) with begin/end values.
- Comprehensive animation blending for combined transitions in `MorphingIcon`.

### Changed
- Bumped minimum Dart SDK to 3.8.0 and Flutter SDK to 3.32.0.
- Updated package version to `0.1.0` and refreshed documentation to describe new capabilities.

### Fixed
- Combined custom animations now animate smoothly when multiple effects (fade, scale, slide, rotate) are enabled simultaneously.
- Resolved inconsistent previous-state tracking that caused morph transitions to jump directly to the final pose.

## [0.0.1] - 2024-12-19

### Added
- Initial release of flutter_morphing_icons package
- Smooth icon morphing animations between different states
- Support for custom icon transitions
- Configurable animation duration and curves
- Multiple morphing animation types
- Example usage and documentation

### Features
- MorphingIcon widget for smooth state transitions
- Customizable animation parameters
- Support for various icon types (Icons, custom widgets)
- Built-in easing curves for natural animations
- Responsive design support

### Documentation
- Comprehensive README with usage examples
- API documentation
- Getting started guide
- Example project included

[0.2.0]: https://github.com/Dhia-Bechattaoui/flutter_morphing_icons/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/Dhia-Bechattaoui/flutter_morphing_icons/releases/tag/v0.1.0
[0.0.1]: https://github.com/Dhia-Bechattaoui/flutter_morphing_icons/releases/tag/v0.0.1
