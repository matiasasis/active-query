# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Filter integration' do
  let!(:dummy1) { DummyModel.create!(name: 'Dummy1', active: false, number: 1) }
  let!(:dummy2) { DummyModel.create!(name: 'Dummy2', active: true, number: 2) }

  describe 'symbol-based type syntax' do
    it 'works with :string type' do
      query_class = Class.new do
        include ActiveQuery::Base
        model_name 'DummyModel'

        query :find_by_name, 'Find by name',
          { name: { type: :string } },
          ->(name:) { scope.where(name: name) }
      end

      expect(query_class.find_by_name(name: 'Dummy1')).to include(dummy1)
    end

    it 'works with :integer type and coercion' do
      query_class = Class.new do
        include ActiveQuery::Base
        model_name 'DummyModel'

        query :find_by_number, 'Find by number',
          { number: { type: :integer } },
          ->(number:) { scope.where(number: number) }
      end

      expect(query_class.find_by_number(number: '1')).to include(dummy1)
    end

    it 'works with :boolean type and coercion' do
      query_class = Class.new do
        include ActiveQuery::Base
        model_name 'DummyModel'

        query :find_active, 'Find active',
          { active: { type: :boolean } },
          ->(active:) { scope.where(active: active) }
      end

      expect(query_class.find_active(active: 'true')).to include(dummy2)
    end

    it 'works with :boolean default values' do
      query_class = Class.new do
        include ActiveQuery::Base
        model_name 'DummyModel'

        query :find_with_default, 'Find with default',
          { active: { type: :boolean, default: true } },
          ->(active:) { scope.where(active: active) }
      end

      expect(query_class.find_with_default).to include(dummy2)
    end

    it 'works with :date type' do
      query_class = Class.new do
        include ActiveQuery::Base
        model_name 'DummyModel'

        query :find_after, 'Find after date',
          { start_date: { type: :date } },
          ->(start_date:) { scope.where('created_at >= ?', start_date) }
      end

      result = query_class.find_after(start_date: '2000-01-01')
      expect(result).to include(dummy1, dummy2)
    end
  end

  describe 'backward compatibility with class-based types' do
    it 'works with type: String' do
      query_class = Class.new do
        include ActiveQuery::Base
        model_name 'DummyModel'

        query :find_by_name, 'Find by name',
          { name: { type: String } },
          ->(name:) { scope.where(name: name) }
      end

      expect(query_class.find_by_name(name: 'Dummy1')).to include(dummy1)
    end

    it 'works with type: Integer' do
      query_class = Class.new do
        include ActiveQuery::Base
        model_name 'DummyModel'

        query :find_by_number, 'Find by number',
          { number: { type: Integer } },
          ->(number:) { scope.where(number: number) }
      end

      expect(query_class.find_by_number(number: 1)).to include(dummy1)
    end

    it 'works with legacy Boolean class' do
      query_class = Class.new do
        include ActiveQuery::Base
        model_name 'DummyModel'

        query :find_active, 'Find active',
          { active: { type: ActiveQuery::Base::Boolean } },
          ->(active:) { scope.where(active: active) }
      end

      expect(query_class.find_active(active: true)).to include(dummy2)
    end
  end
end
