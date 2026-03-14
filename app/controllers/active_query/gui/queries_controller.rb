# frozen_string_literal: true

module ActiveQuery
  module GUI
    class QueriesController < ActionController::Base
      layout false
      skip_forgery_protection only: [:execute]

      def index
        respond_to do |format|
          format.html
          format.json { render json: grouped_queries }
        end
      end

      def execute
        klass = find_query_class!(params[:query_class])
        query_name = params[:query_name].to_sym
        query_def = find_query_def!(klass, query_name)
        args = coerce_args(params[:args], query_def[:args_def] || {})

        result = if args.empty?
                   klass.public_send(query_name)
                 else
                   klass.public_send(query_name, args)
                 end

        render json: { result: serialize_result(result) }
      rescue ArgumentError, NameError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue => e
        render json: { error: "#{e.class}: #{e.message}" }, status: :internal_server_error
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

      def find_query_class!(name)
        ActiveQuery::Base.registry.find { |k| k.name == name } or
          raise NameError, "Unknown query class: #{name}"
      end

      def find_query_def!(klass, query_name)
        (klass.queries || []).find { |q| q[:name] == query_name } or
          raise NameError, "Unknown query :#{query_name} on #{klass.name}"
      end

      def coerce_args(args_hash, args_def)
        return {} if args_hash.blank?

        args_hash.to_unsafe_h.symbolize_keys.each_with_object({}) do |(key, value), result|
          next if value.blank? && (args_def.dig(key, :optional) == true)

          type = args_def.dig(key, :type)
          result[key] = coerce_value(value, type)
        end
      end

      def coerce_value(value, type)
        case type&.name
        when "Integer" then Integer(value)
        when "Float" then Float(value)
        when "ActiveQuery::Base::Boolean" then ActiveModel::Type::Boolean.new.cast(value)
        else value.to_s
        end
      end

      def serialize_result(result)
        case result
        when ActiveRecord::Relation then result.limit(100).as_json
        when Integer, Float, String, NilClass, TrueClass, FalseClass then result
        when ActiveRecord::Base then result.as_json
        when Enumerable then result.first(100).as_json
        else result.as_json
        end
      end
    end
  end
end
