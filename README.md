# ActiveQuery

ActiveQuery is a gem that helps you create query objects in a simple way. It provides a DSL to define queries and scopes for your query object, making it easier to organize and reuse complex database queries.

## Features

- **Query Objects**: Create reusable query objects with a clean DSL
- **Type Validation**: Built-in argument type validation
- **Scopes**: Define custom scopes for your queries
- **Operations**: Additional query operations like `gt`, `lt`, `like`, etc.
- **Resolvers**: Support for resolver pattern for complex queries
- **ActiveRecord Integration**: Works seamlessly with ActiveRecord models

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active-query'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install active-query
```

## Usage

### Basic Query Object

Create a query object by including `ActiveQuery::Base`:

```ruby
class UserQuery
  include ActiveQuery::Base
  
  # The model is automatically inferred from the class name (User)
  # Or you can explicitly set it:
  # model_name 'User'
  
  query :by_email, 'Find users by email', { email: { type: String } } do |email:|
    scope.where(email: email)
  end
  
  query :active, 'Find active users' do
    scope.where(active: true)
  end
end
```

### Using Query Objects

```ruby
# Find users by email
users = UserQuery.by_email(email: 'john@example.com')

# Find active users
active_users = UserQuery.active

# Chain queries
active_users_with_email = UserQuery.active.by_email(email: 'john@example.com')
```

### Query Arguments with Types

```ruby
class ProductQuery
  include ActiveQuery::Base
  
  query :by_price_range, 'Find products within price range', {
    min_price: { type: Float },
    max_price: { type: Float, optional: true },
    include_tax: { type: ActiveQuery::Base::Boolean, default: false }
  } do |min_price:, max_price:, include_tax:|
    scope.where('price >= ?', min_price)
         .then { |s| max_price ? s.where('price <= ?', max_price) : s }
         .then { |s| include_tax ? s.where(tax_included: true) : s }
  end
end

# Usage
products = ProductQuery.by_price_range(min_price: 10.0, max_price: 100.0, include_tax: true)
```

### Custom Scopes

Define reusable scopes within your query object:

```ruby
class OrderQuery
  include ActiveQuery::Base
  include ActiveQuery::Scopes
  
  scope :recent, -> { where('created_at > ?', 1.week.ago) }
  scope :completed, -> { where(status: 'completed') }
  
  query :recent_completed, 'Find recent completed orders' do
    scope.recent.completed
  end
end
```

### Operations

ActiveQuery provides additional query operations:

```ruby
class UserQuery
  include ActiveQuery::Base
  
  query :by_age_range, 'Find users by age range', {
    min_age: { type: Integer, optional: true },
    max_age: { type: Integer, optional: true }
  } do |min_age:, max_age:|
    scope.then { |s| min_age ? s.gteq(:age, min_age) : s }
         .then { |s| max_age ? s.lteq(:age, max_age) : s }
  end
  
  query :by_name, 'Find users by name pattern', { name: { type: String } } do |name:|
    scope.like(:name, name)
  end
end
```

Available operations:
- `gt(column, value)` - greater than
- `gteq(column, value)` - greater than or equal
- `lt(column, value)` - less than  
- `lteq(column, value)` - less than or equal
- `like(column, value)` - contains pattern
- `start_like(column, value)` - starts with pattern
- `end_like(column, value)` - ends with pattern

### Resolvers

For complex queries, you can use the resolver pattern:

```ruby
class UserStatsResolver < ActiveQuery::Resolver
  def resolve(status: nil)
    query = scope.joins(:orders)
    query = query.where(status: status) if status
    query.group(:id).having('COUNT(orders.id) > 5')
  end
end

class UserQuery
  include ActiveQuery::Base
  
  query :with_many_orders, 'Users with many orders', {
    status: { type: String, optional: true }
  }, resolver: UserStatsResolver
end

# Usage
users = UserQuery.with_many_orders(status: 'active')
```

### Conditional Queries

Use `if` and `unless` for conditional query building:

```ruby
class ProductQuery
  include ActiveQuery::Base
  
  query :search, 'Search products', {
    name: { type: String, optional: true },
    category: { type: String, optional: true },
    on_sale: { type: ActiveQuery::Base::Boolean, optional: true }
  } do |name:, category:, on_sale:|
    scope.if(name.present?, -> { where('name ILIKE ?', "%#{name}%") })
         .if(category.present?, -> { where(category: category) })
         .if(on_sale == true, -> { where('sale_price IS NOT NULL') })
  end
end
```

## Requirements

- Ruby >= 2.6.0
- ActiveRecord >= 6.1
- ActiveSupport >= 6.1

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/matiasasis/active-query. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/matiasasis/active-query/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveQuery project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/matiasasis/active-query/blob/master/CODE_OF_CONDUCT.md).