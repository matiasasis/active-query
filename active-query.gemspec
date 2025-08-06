# frozen_string_literal: true

require_relative "lib/active_query/version"

Gem::Specification.new do |spec|
  spec.name = "active-query"
  spec.version = ActiveQuery::VERSION
  spec.authors = ["Matias Asis"]
  spec.email = ["matiasis.90@gmail.com"]

  spec.summary = "ActiveQuery is a gem that helps you to create query objects in a simple way."
  spec.description = "ActiveQuery is a gem that helps you to create query objects in a simple way. It provides a DSL to define queries and scopes for your query object."
  spec.homepage = "https://github.com/matiasasis/active-query"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/matiasasis/active-query"
  spec.metadata["bug_tracker_uri"] = "https://github.com/matiasasis/active-query/issues"
  spec.metadata["changelog_uri"] = "https://github.com/matiasasis/active-query/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile]) ||
        f.match?(/\.gem\z/)
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'activerecord', '>= 6.1', '< 8.0'
  spec.add_dependency 'activesupport', '>= 6.1', '< 8.0'

  # Dev dependencies
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'simplecov', '~> 0.17.1'
  spec.add_development_dependency 'sqlite3', '~> 1.5.1'
  spec.add_development_dependency 'database_cleaner-active_record', '~> 2.2.0'
  spec.add_development_dependency 'byebug', '~> 11.0'
end
