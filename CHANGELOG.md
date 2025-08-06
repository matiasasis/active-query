# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/matiasasis/active-query/compare/v0.0.1...HEAD
[0.0.1]: https://github.com/matiasasis/active-query/releases/tag/v0.0.1