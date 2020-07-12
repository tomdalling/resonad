# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2020-07-12
### Added
- more documentation
- support for Ruby 2.7 pattern matching
- `#otherwise` alias for `#or_else`
- `#map_value` alias for `#map`
- alternate constructor methods
- aliases for `#on_success` and `#on_failure`
- `Success` and `Failure` class constants to `Resonad::Mixin`
- `Resonad::PublicMixin` for people who want the previous behaviour of
  `Resonad::Mixin`
### Changed
- The methods provided by `Resonad::Mixin` are now private. Replace with
  `Resonad::PublicMixin` to revert them back to being public.

## [1.2.0] - 2017-05-22
### Added
- `Resonad.Success()` and `Resonad.Failure()` arguments are optional, and
  default to nil.
- `#successful?` and `#ok?` as new aliases for `#success?`
- `#failed?` and `#bad?` as new aliases for `#failure?`

## [1.1.1] - 2017-05-09
### Fixed
- Aliased methods `#and_then` and `#or_else` were not aliased properly.

## [1.1.0] - 2017-05-01
### Added
- `Resonad::Mixin`
### Changed
- `Resonad` is now a class. `Resonad::Success` and `Resonad::Failure` now
  inherit from `Resonad`.

## [1.0.2] - 2017-04-22
### Fixed
- Typo in class names

## [1.0.1] - 2017-04-22
### Changed
- Nothing (bumped to force a deploy)

## [1.0.0] - 2017-04-22
### Added
- Everything (initial release)
