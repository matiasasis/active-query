# frozen_string_literal: true

module ActiveQuery
  module GUI
    class QueriesController < ActionController::Base
      def index
        render json: grouped_queries
      end

      private

      def grouped_queries
        query_classes = ActiveQuery::Base.registry.select { |k| k.is_a?(Class) }
        query_classes.group_by { |klass| namespace_for(klass) }.map do |namespace, klasses|
          {
            namespace: namespace,
            query_objects: klasses.map { |k| query_object_payload(k) }
          }
        end
      end

      def query_object_payload(klass)
        {
          class_name: klass.name,
          source_location: source_location_for(klass),
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

      def source_location_for(klass)
        file, line = Object.const_source_location(klass.name)
        return nil unless file

        { file: file, line: line }
      end

      def namespace_for(klass)
        name = klass.name.to_s
        last_separator = name.rindex("::")
        last_separator ? name[0...last_separator] : ""
      end
    end
  end
end
