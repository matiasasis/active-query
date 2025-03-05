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
  end
end
