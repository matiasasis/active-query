# frozen_string_literal: true

module ActiveRecordRelationExtensions
  extend ActiveSupport::Concern

  # Adds the `if` method to ActiveRecord::Relation
  module ClassMethods
    # `if` applies the given scope only if the condition is true.
    #
    # @param if_condition [Boolean] whether to apply the scope
    # @param scope [Proc] a callable object representing the scope
    # @return [ActiveRecord::Relation] the modified or original relation
    def if(if_condition, scope)
      return self unless if_condition

      raise "Invalid Scope. Must provide a lambda '-> { your_scope(arg) }'" unless scope.is_a?(Proc)

      merge(scope)
    end

    # `if` applies the given scope only if the condition is true.
    #
    # @param if_condition [Boolean] whether to apply the scope
    # @param scope [Proc] a callable object representing the scope
    # @return [ActiveRecord::Relation] the modified or original relation
    def unless(unless_condition, scope)
      return self if unless_condition

      raise "Invalid Scope. Must provide a lambda '-> { your_scope(arg) }'" unless scope.is_a?(Proc)

      merge(scope)
    end
  end
end

ActiveRecord::Relation.include(ActiveRecordRelationExtensions::ClassMethods)
