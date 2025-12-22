# Rails 8 Migration Guide for ActiveQuery

This guide covers the changes needed to use ActiveQuery with Rails 8.0 and how to migrate from earlier versions.

## Key Changes in Rails 8

### SQLite3 Version Requirement

**Rails 8 requires SQLite3 version 2.1 or higher**, which is a breaking change from previous Rails versions that used SQLite3 1.x.

#### Before (Rails 7.x)
```ruby
gem 'sqlite3', '~> 1.4'
```

#### After (Rails 8.0)
```ruby
gem 'sqlite3', '~> 2.1'
```

### ActiveQuery Compatibility

ActiveQuery maintains compatibility with Rails 8 through:

- Updated dependency constraints: `activerecord >= 6.1, < 9.0`
- Flexible SQLite3 version support in gemspec: `sqlite3 >= 1.5.1, < 3.0`
- Separate gemfiles for testing different Rails versions

## Migration Steps

### 1. Update Your Gemfile

If you're upgrading to Rails 8, update your SQLite3 version:

```ruby
# Gemfile
gem 'rails', '~> 8.0'
gem 'sqlite3', '~> 2.1'  # Required for Rails 8
gem 'active-query'
```

### 2. Bundle Update

```bash
bundle update rails sqlite3
```

### 3. Test Your Application

ActiveQuery should work without changes, but test your query objects:

```ruby
# Your existing query objects should continue to work
class UserQuery
  include ActiveQuery::Base
  
  query :active, 'Active users', -> { scope.where(active: true) }
end

UserQuery.active # Should work the same in Rails 8
```

## Version Compatibility Matrix

| Rails Version | SQLite3 Version | ActiveQuery Support |
|---------------|-----------------|-------------------|
| 6.1.x         | ~> 1.4          | ✅ Supported      |
| 7.0.x         | ~> 1.4          | ✅ Supported      |
| 7.1.x         | ~> 1.4          | ✅ Supported      |
| 8.0.x         | ~> 2.1          | ✅ Supported      |

## Testing Across Rails Versions

### For Gem Development

If you're contributing to ActiveQuery or maintaining a fork:

```bash
# Test all supported Rails versions
./bin/test_all_rails

# Test specific Rails version
BUNDLE_GEMFILE=gemfiles/rails_8_0.gemfile bundle exec rake spec
```

### Using Appraisal

```bash
# Install all version gemfiles
bundle exec appraisal install

# Test Rails 8 specifically  
bundle exec appraisal rails-8-0 rake spec
```

## Common Issues and Solutions

### Issue: SQLite3 Version Conflict

**Error:**
```
can't activate sqlite3 (>= 2.1), already activated sqlite3-1.5.4
```

**Solution:**
1. Update your Gemfile to use `sqlite3 ~> 2.1` for Rails 8
2. Run `bundle update sqlite3`
3. Clear any cached bundler state: `bundle install --redownload`

### Issue: Dependency Resolution

**Error:**
```
Bundler could not find compatible versions for gem "sqlite3"
```

**Solution:**
Use version constraints that work with your Rails version:

```ruby
# For Rails 8
gem 'sqlite3', '~> 2.1'

# For Rails 7 and below  
gem 'sqlite3', '~> 1.4'

# Or use flexible constraint (not recommended for production)
gem 'sqlite3', '>= 1.4', '< 3.0'
```

## Database Considerations

### SQLite3 2.x Changes

SQLite3 2.x includes:
- Performance improvements
- Better Ruby 3.x compatibility  
- Updated native extensions

### Migration Notes

- Database files created with SQLite3 1.x are compatible with 2.x
- No schema changes required
- Existing ActiveQuery functionality unchanged

## CI/CD Updates

### GitHub Actions

Update your workflow to handle different SQLite3 versions:

```yaml
- name: Install dependencies
  run: |
    if [ "${{ matrix.rails-version }}" = "8.0" ]; then
      bundle add sqlite3 --version "~> 2.1"
    else  
      bundle add sqlite3 --version "~> 1.4"
    fi
    bundle install
```

### Docker

Update your Dockerfile for Rails 8:

```dockerfile
# For Rails 8 applications
RUN bundle add sqlite3 --version "~> 2.1"
```

## Rollback Strategy

If you need to rollback from Rails 8:

1. Downgrade Rails in Gemfile: `gem 'rails', '~> 7.1'`
2. Downgrade SQLite3: `gem 'sqlite3', '~> 1.4'`  
3. Run `bundle update rails sqlite3`

ActiveQuery will continue to work without code changes.

## Support

- ActiveQuery supports Rails 6.1 through 8.0
- SQLite3 version requirements are handled automatically in our test matrix
- Report issues at: https://github.com/matiasasis/active-query/issues

## Further Reading

- [Rails 8.0 Release Notes](https://guides.rubyonrails.org/8_0_release_notes.html)
- [SQLite3 Ruby Gem Changelog](https://github.com/sparklemotion/sqlite3-ruby/blob/main/CHANGELOG.md)
- [ActiveQuery GitHub Repository](https://github.com/matiasasis/active-query)