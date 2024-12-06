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

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/matiasasis/active-query"
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  # gemspec = File.basename(__FILE__)
  # spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
  #   ls.readlines("\x0", chomp: true).reject do |f|
  #     (f == gemspec) ||
  #       f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
  #   end
  # end
  # spec.bindir = "exe"
  # spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files = Dir['LICENSE.txt', 'README.md', 'lib/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', ['>= 5.2']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  # spec.add_development_dependency 'ammeter', '~> 1.1'
  # spec.add_development_dependency 'database_cleaner-active_record', '~> 1.8.0'
  # spec.add_development_dependency 'rake', '~> 13.0.1'
  # spec.add_development_dependency 'reek', '~> 6.0.6'
  # spec.add_development_dependency 'rspec', '~> 3.9.0'
  # spec.add_development_dependency 'rubocop', '~> 1.24.1'
  # spec.add_development_dependency 'simplecov', '~> 0.17.1'
  # spec.add_development_dependency 'sqlite3', '~> 1.4.2'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

end
