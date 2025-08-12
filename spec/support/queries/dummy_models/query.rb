# frozen_string_literal: true

module DummyModels
  class Query
    include ::ActiveQuery::Base
    model_name 'DummyModel'

    query :count, 'Returns DummyModel count', -> { scope.count }

    query :by_name, 'Returns the dummy models that match exact name',
      { name: { type: String, optional: false } },
      -> (name:) { scope.where(name: name) }

    query :count_resolver, 'Returns DummyModel count through the resolver', resolver: DummyModels::Resolvers::Count

    query :by_name_resolver, 'Returns the dummy models that match exact name through the resolver',
      { name: { type: String } },
      resolver: DummyModels::Resolvers::ByName

    query :all_args, 'Returns the dummy models that match the filters',
      {
        name: { type: String },
        active: { type: Boolean },
        number: { type: Integer }
      },
      -> (name:, active:, number:) { scope.where(name:).where(active:).where(number:) }

    query :example_with_default, 'Returns the dummy models that match exact name',
      {
        number: { type: Integer },
        active: { type: Boolean, default: true },
        name: { type: String, optional: true }
      },
      -> (number:, active:, name:) { scope.where(number:).where(active:) }

    query :number_if_active, 'Returns all that match number and active (if provided)',
      {
        number: { type: Integer },
        active: { type: Boolean, optional: true },
      },
      -> (number:, active:) {
        scope
          .where(number:)
          .if(active, -> { where(active:) })
      }

    query :number_unless_active, 'Returns all that match number and active, if active not provided will use true',
      {
        number: { type: Integer },
        active: { type: Boolean, optional: true },
      },
      -> (number:, active:) {
        scope
          .where(number:)
          .unless(active, -> { where(active: true) })
      }

    query :greater_than, 'Returns all with number > 1', -> { scope.gt(:number, 1) }

    query :greater_than_or_equals, 'Returns all with number >= 1', -> { scope.gteq(:number, 1) }

    query :less_than, 'Returns all with number < 2', -> { scope.lt(:number, 2) }

    query :less_than_or_equals, 'Returns all with number <= 2', -> { scope.lteq(:number, 2) }

    query :like_name, 'Returns with name like Dummy', -> { scope.like(:name, 'Dummy') }

    query :start_like_name, 'Returns with name that start like Dummy', -> { scope.start_like(:name, 'Dummy') }

    query :end_like_name, 'Returns with name that end like 1', -> { scope.end_like(:name, '1') }

    query :by_number, 'Returns with number matching argument',
      { number: { type: Integer } }, -> (number:) { scope.where(number:) }

    query :count_with_scope, 'Returns the count of the scope', -> { scope.count_scope }

    query :only_optional_argument,
      'Tests whether query supports only 1 argument that is optional',
      { number: { type: Integer, optional: true } },
      -> (number:) {
        scope.if(number, -> { where(number: number) }).count
      }

    module Scopes
      include ::ActiveQuery::Scopes

      scope :by_number, -> (number:) { where(number: number) }

      scope :count_scope, -> { count }
    end
  end
end
