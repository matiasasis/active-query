# ActiveQuery

ActiveQuery is a Ruby gem that helps you create clean, reusable query objects with a simple DSL. It provides type validation, conditional logic, and seamless ActiveRecord integration.

## Features

- **Clean Query DSL**: Define queries with clear syntax and descriptions
- **Type Safety**: Built-in argument type validation (String, Integer, Float, Boolean)
- **Optional & Default Arguments**: Flexible argument handling
- **Custom Operations**: Extended query operations like `gt`, `lt`, `like`, etc.
- **Conditional Logic**: Apply scopes conditionally with `if` and `unless`
- **Resolver Pattern**: Support for complex query logic in separate classes
- **Custom Scopes**: Define reusable scopes within query objects
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

## Usage

### Basic Query Object

Create a query object by including `ActiveQuery::Base` and defining queries with the `query` method:

```ruby
class UserQuery
  include ActiveQuery::Base

  # The model is automatically inferred from the class name (User)
  # Or explicitly set it:
  model_name 'User'

  # Simple query without arguments
  query :active, 'Returns all active users', -> { scope.where(active: true) }

  # Query with arguments and type validation
  query :by_email, 'Find users by email address',
    { email: { type: String } },
    -> (email:) { scope.where(email: email) }
end
```

### Using Query Objects

```ruby
# Execute queries
active_users = UserQuery.active
user = UserQuery.by_email(email: 'john@example.com')

# Chain with ActiveRecord methods
recent_active_users = UserQuery.active.where('created_at > ?', 1.week.ago)
```

### Argument Types and Validation

ActiveQuery supports several argument types with automatic validation:

```ruby
class ProductQuery
  include ActiveQuery::Base

  query :filter_products, 'Filter products by various criteria',
    {
      name: { type: String },
      price: { type: Float },
      quantity: { type: Integer },
      available: { type: Boolean }
    },
    -> (name:, price:, quantity:, available:) {
      scope.where(name: name)
           .where(price: price)
           .where(quantity: quantity)
           .where(available: available)
    }
end

# Usage with type validation
ProductQuery.filter_products(
  name: 'Widget',
  price: 19.99,
  quantity: 10,
  available: true
)

# This will raise ArgumentError due to type mismatch
ProductQuery.filter_products(name: 123, price: 'invalid', quantity: true, available: 'yes')
```

### Optional Arguments and Defaults

```ruby
class OrderQuery
  include ActiveQuery::Base

  query :search_orders, 'Search orders with optional filters',
    {
      status: { type: String },
      paid: { type: Boolean, default: true },
      customer_name: { type: String, optional: true }
    },
    -> (status:, paid:, customer_name:) {
      scope.where(status: status)
           .where(paid: paid)
           .if(customer_name, -> { where('customer_name LIKE ?', "%#{customer_name}%") })
    }
end

# Usage - customer_name is optional, paid defaults to true
OrderQuery.search_orders(status: 'pending')
OrderQuery.search_orders(status: 'completed', customer_name: 'John')
OrderQuery.search_orders(status: 'pending', paid: false, customer_name: 'Jane')
```

### Conditional Query Logic

Use `if` and `unless` methods for conditional query building:

```ruby
class UserQuery
  include ActiveQuery::Base

  query :search_users, 'Search users with conditional filters',
    {
      name: { type: String, optional: true },
      active: { type: Boolean, optional: true }
    },
    -> (name:, active:) {
      scope.if(name.present?, -> { where('name LIKE ?', "%#{name}%") })
           .if(active == true, -> { where(active: true) })
    }

  query :filter_unless_admin, 'Filter users unless they are admin',
    {
      role: { type: String, optional: true }
    },
    -> (role:) {
      scope.unless(role == 'admin', -> { where.not(role: 'admin') })
    }
end
```

### Extended Query Operations

ActiveQuery provides additional query operations beyond standard ActiveRecord:

```ruby
class ProductQuery
  include ActiveQuery::Base

  # Comparison operations
  query :expensive_products, 'Products above price threshold', -> { scope.gt(:price, 100) }
  query :affordable_products, 'Products within budget', -> { scope.lteq(:price, 50) }

  # Text search operations
  query :search_by_name, 'Search products by name pattern', -> { scope.like(:name, 'Phone') }
  query :products_starting_with, 'Products starting with prefix', -> { scope.start_like(:name, 'iPhone') }
  query :products_ending_with, 'Products ending with suffix', -> { scope.end_like(:name, 'Pro') }

  # Dynamic filtering
  query :by_price_range, 'Filter by price range',
    { min_price: { type: Float }, max_price: { type: Float } },
    -> (min_price:, max_price:) {
      scope.gteq(:price, min_price)
           .lteq(:price, max_price)
    }
end
```

**Available operations:**
- `gt(column, value)` - greater than
- `gteq(column, value)` - greater than or equal
- `lt(column, value)` - less than
- `lteq(column, value)` - less than or equal
- `like(column, value)` - contains pattern (wraps with %)
- `start_like(column, value)` - starts with pattern
- `end_like(column, value)` - ends with pattern

### Custom Scopes

Define reusable scopes within your query objects:

```ruby
class UserQuery
  include ActiveQuery::Base
  include ActiveQuery::Scopes

  # Define custom scopes
  module Scopes
    include ActiveQuery::Scopes

    scope :recent, -> { where('created_at > ?', 1.month.ago) }
    scope :by_role, -> (role:) { where(role: role) }
  end

  # Use scopes in queries
  query :recent_admins, 'Find recent admin users', -> { scope.recent.by_role(role: 'admin') }

  query :count_recent, 'Count recent users', -> { scope.recent.count }
end
```

### Resolver Pattern

For complex query logic, use the resolver pattern to keep your query objects clean:

```ruby
# Define a resolver
class UserStatsResolver < ActiveQuery::Resolver
  def resolve(min_orders: 5)
    scope.joins(:orders)
         .group('users.id')
         .having('COUNT(orders.id) >= ?', min_orders)
         .select('users.*, COUNT(orders.id) as order_count')
  end
end

# Use resolver in query object
class UserQuery
  include ActiveQuery::Base

  # Resolver without arguments
  query :high_value_users, 'Users with many orders',
    resolver: UserStatsResolver

  # Resolver with arguments
  query :users_with_orders, 'Users with minimum order count',
    { min_orders: { type: Integer } },
    resolver: UserStatsResolver
end

# Usage
UserQuery.high_value_users
UserQuery.users_with_orders(min_orders: 10)
```

### Query Introspection

Query objects provide metadata about available queries:

```ruby
class UserQuery
  include ActiveQuery::Base

  query :active, 'Find active users', -> { scope.where(active: true) }
  query :by_name, 'Find by name', { name: { type: String } }, -> (name:) { scope.where(name: name) }
end

# Get all available queries
UserQuery.queries
# => [
#   { name: :active, description: "Find active users", args_def: {} },
#   { name: :by_name, description: "Find by name", args_def: { name: { type: String } } }
# ]
```

### Error Handling

ActiveQuery provides clear error messages for common mistakes:

```ruby
# Missing required arguments
UserQuery.by_email
# => ArgumentError: Params missing: [:email]

# Wrong argument type
UserQuery.by_email(email: 123)
# => ArgumentError: :email must be of type String

# Unknown arguments
UserQuery.by_email(email: 'test@example.com', invalid_param: 'value')
# => ArgumentError: Unknown params: [:invalid_param]

# Optional and default together (validation error)
query :invalid_query, 'This will fail',
  { param: { type: String, optional: true, default: 'value' } },
  -> (param:) { scope }
# => ArgumentError: Optional and Default params can't be present together: [:param]
```

### Integration with Rails

ActiveQuery works seamlessly with Rails applications:

```ruby
# app/queries/user_query.rb
class UserQuery
  include ActiveQuery::Base

  query :active, 'Active users', -> { scope.where(active: true) }
  query :by_role, 'Users by role', { role: { type: String } }, -> (role:) { scope.where(role: role) }
end

# In controllers
class UsersController < ApplicationController
  def index
    @users = UserQuery.active
  end

  def admins
    @admins = UserQuery.by_role(role: 'admin')
  end
end

# In views or anywhere else
<%= UserQuery.active.count %> active users
```

## Requirements

- Ruby >= 3.2.0
- ActiveRecord >= 6.1, < 9.0
- ActiveSupport >= 6.1, < 9.0

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/matiasasis/active-query. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/matiasasis/active-query/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveQuery project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/matiasasis/active-query/blob/master/CODE_OF_CONDUCT.md).
