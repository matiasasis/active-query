# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.1] - 2026-03-19

### Added
- `ActiveQuery::Base.registry` — a global registry tracking all classes that include `ActiveQuery::Base`, enabling programmatic discovery of query objects in an application

### Fixed
- Registry support for intermediary concern pattern (e.g. classes that include `ActiveQuery::Base` through an intermediate concern like `HireartQuery::Base`)
- Guard `infer_model` against anonymous classes with nil name

## [0.2.0] - 2026-03-11

### Added
- `ActiveQuery::TypeRegistry` for extensible type validation and coercion — register custom types via `TypeRegistry.register` with a `type_class:`, custom validator lambda, or coercer lambda
- Built-in type classes (`Types::String`, `Types::Integer`, `Types::Float`, `Types::Boolean`) with default coercion support
- Per-argument `coerce:` option in argument definitions, taking priority over registry-level coercion
- `TypeRegistry.unregister` to disable built-in coercion and fall back to strict `is_a?` validation
- Integer coercion restricted to base-10 strings to prevent unexpected hex/octal conversions

### Fixed
- Replace `instance_of?` with `is_a?` in type validation so subclass instances (e.g. `ActiveSupport::SafeBuffer`) pass `String` type checks

## [0.1.3] - 2024-12-19

### Added
- Support for Rails 8.0
- Compatibility with SQLite3 version 2.1+ required by Rails 8
- Updated CI matrix to test against Rails 8.0

## [0.0.1] - 2024-12-19

### Added
- Initial release of ActiveQuery gem
- Query object DSL with `ActiveQuery::Base` module
- Type validation for query arguments (String, Integer, Float, Boolean)
- Support for optional arguments and default values
- Custom scopes with `ActiveQuery::Scopes` module
- Additional query operations: `gt`, `gteq`, `lt`, `lteq`, `like`, `start_like`, `end_like`
- Resolver pattern support for complex queries
- Conditional query building with `if` and `unless` methods
- Automatic model inference from class names
- ActiveRecord integration with Rails 6.1+ support
- Comprehensive test suite with 100% code coverage
- GitHub Actions CI/CD pipeline

### Features
- **Query Objects**: Create reusable query objects with clean DSL
- **Type Safety**: Built-in argument validation
- **Scopes**: Define custom scopes for queries
- **Operations**: Extended query operations beyond standard ActiveRecord
- **Resolvers**: Support complex query logic with resolver classes
- **Conditional Logic**: Apply scopes conditionally with `if`/`unless`

[Unreleased]: https://github.com/matiasasis/active-query/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/matiasasis/active-query/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/matiasasis/active-query/compare/v0.1.3...v0.2.0
[0.1.3]: https://github.com/matiasasis/active-query/compare/v0.0.1...v0.1.3
[0.0.1]: https://github.com/matiasasis/active-query/releases/tag/v0.0.1