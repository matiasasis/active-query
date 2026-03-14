# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query Discovery' do
  describe 'grouped queries from registry' do
    let(:grouped) do
      ActiveQuery::Base.registry.group_by { |klass|
        name = klass.name.to_s
        last_separator = name.rindex("::")
        last_separator ? name[0...last_separator] : ""
      }.map do |namespace, klasses|
        {
          namespace: namespace,
          query_objects: klasses.map { |k| build_payload(k) }
        }
      end
    end

    def build_payload(klass)
      {
        class_name: klass.name,
        queries: (klass.queries || []).map do |q|
          {
            name: q[:name],
            description: q[:description],
            params: (q[:args_def] || {}).map do |name, config|
              {
                name: name,
                type: config[:type]&.name,
                optional: config[:optional] || false,
                default: config[:default]
              }.compact
            end
          }
        end
      }
    end

    it 'groups queries by namespace' do
      namespaces = grouped.map { |g| g[:namespace] }
      expect(namespaces).to include('DummyModels')
    end

    it 'includes query objects within their namespace' do
      dummy_group = grouped.find { |g| g[:namespace] == 'DummyModels' }
      class_names = dummy_group[:query_objects].map { |qo| qo[:class_name] }
      expect(class_names).to include('DummyModels::Query')
    end

    it 'includes query details with name and description' do
      dummy_group = grouped.find { |g| g[:namespace] == 'DummyModels' }
      query_obj = dummy_group[:query_objects].find { |qo| qo[:class_name] == 'DummyModels::Query' }
      query_names = query_obj[:queries].map { |q| q[:name] }

      expect(query_names).to include(:count)
      expect(query_names).to include(:by_name)
    end

    it 'includes parameter definitions for queries with args' do
      dummy_group = grouped.find { |g| g[:namespace] == 'DummyModels' }
      query_obj = dummy_group[:query_objects].find { |qo| qo[:class_name] == 'DummyModels::Query' }
      by_name = query_obj[:queries].find { |q| q[:name] == :by_name }

      expect(by_name[:params]).to include(
        hash_including(name: :name, type: 'String', optional: false)
      )
    end

    it 'returns empty params for queries without args' do
      dummy_group = grouped.find { |g| g[:namespace] == 'DummyModels' }
      query_obj = dummy_group[:query_objects].find { |qo| qo[:class_name] == 'DummyModels::Query' }
      count = query_obj[:queries].find { |q| q[:name] == :count }

      expect(count[:params]).to eq([])
    end
  end
end
