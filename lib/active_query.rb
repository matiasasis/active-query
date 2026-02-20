# frozen_string_literal: true

require 'active_record'
require 'active_support'
require 'active_support/concern'
require_relative 'active_query/version'
require_relative 'active_query/resolver'
require_relative 'active_query/filters/base'
require_relative 'active_query/filters/string_filter'
require_relative 'active_query/filters/integer_filter'
require_relative 'active_query/filters/float_filter'
require_relative 'active_query/filters/boolean_filter'
require_relative 'active_query/filters/date_filter'
require_relative 'active_query/filters/date_time_filter'
require_relative 'active_query/filters/symbol_filter'
require_relative 'active_query/filters/decimal_filter'
require_relative 'active_query/filters/record_filter'
require_relative 'active_query/filters/array_filter'
require_relative 'active_query/filters/hash_filter'
require_relative 'active_query/filters/registry'
require_relative 'active_record_relation_extensions'

module ActiveQuery
  module Base
    extend ::ActiveSupport::Concern

    class Boolean; end

    included do
      infer_model
      @__queries = []
    end

    class_methods do
      def model_name(model_name)
        classified_model_name = model_name.classify
        model = classified_model_name.safe_constantize
        raise NameError, "Model #{classified_model_name} not found" unless model
        raise ArgumentError, 'Model should be an ActiveRecord::Base' unless model.ancestors.include?(ActiveRecord::Base)

        @__model = model
      end

      def model
        @__model
      end

      def scope
        raise ArgumentError, "Model not defined. Add model_name('Your::Model') to your QueryObject" unless @__model

        @__scope ||= begin
          relation = @__model.all.extending(Operations)
          if self.name && const_defined?(scopes_module_name)
            relation = relation.extending(scopes_module_name.constantize)
          end
          relation
        end
      end

      # Will list all queries available on query object.
      def queries
        @__queries
      end

      def query(name, description, args_def_or_lambda = nil, lambda = nil, **kwargs)
        raise ArgumentError, 'name must be present' unless name.present?

        if args_def_or_lambda.is_a?(Hash)
          if kwargs[:resolver].present?
            query_with_resolver(name, description, args_def_or_lambda, **kwargs)
          else
            query_with_arguments(name, description, args_def_or_lambda, lambda)
          end
        elsif args_def_or_lambda.is_a?(Proc)
          query_without_args(name, description, args_def_or_lambda)
        elsif args_def_or_lambda.nil? && kwargs[:resolver].present?
          query_with_resolver_without_out_args(name, description, **kwargs)
        else
          raise ArgumentError, 'Invalid query definition'
        end
      end

      private

      def scopes_module_name
        "#{self}::Scopes"
      end

      def infer_model
        return unless self.name

        model_class_name = self.name.sub(/::Query$/, '').classify
        return unless const_defined?(model_class_name)

        model = model_class_name.safe_constantize
        return unless model.ancestors.include?(ActiveRecord::Base)

        model_name(model_class_name)
      end

      def query_with_arguments(name, description, args_def, lambda)
        register_query(name, description, args_def)

        define_singleton_method(name) do |given_args = {}|
          given_args = validate_args(name, given_args, args_def)
          lambda.call(**given_args)
        end
      end

      def query_without_args(name, description, lambda)
        register_query(name, description)
        define_singleton_method(name) { lambda.call }
      end

      def query_with_resolver(name, description, args_def, **kwargs)
        register_query(name, description, args_def)
        resolver = kwargs[:resolver]
        raise 'Invalid Resolver, must inherit from ActiveQuery::Resolvers::Base' unless resolver.ancestors.include?(ActiveQuery::Resolver)

        define_singleton_method(name) do |given_args|
          given_args = validate_args(name, given_args, args_def)
          resolver.new(scope).resolve(**given_args)
        end
      end

      def query_with_resolver_without_out_args(name, description, **kwargs)
        register_query(name, description)
        resolver = kwargs[:resolver]
        raise 'Invalid Resolver, must inherit from ActiveQuery::Resolvers::Base' unless resolver.ancestors.include?(ActiveQuery::Resolver)

        define_singleton_method(name) { resolver.new(scope).resolve }
      end

      def register_query(name, description, args_def = {})
        # Validate optional and default are not present together
        optional_and_default = args_def.select { |key, value| value[:optional] == true && value[:default].present? }
        raise ArgumentError, "Optional and Default params can't be present together: #{optional_and_default.keys}" if optional_and_default.present?

        # Will add all queries for further serving the method 'queries'
        @__queries << { name:, description:, args_def: }.compact_blank
      end

      def validate_args(name, given_args, args_def)
        # Validate if the given arguments are correct
        raise ArgumentError, "Incorrect Params, must be called '.#{name}(#{args_def.keys.map { |p| "#{p}: value" }.join(', ')})' " unless given_args.is_a?(Hash)

        # Build filter objects for each argument definition
        filters = args_def.each_with_object({}) do |(arg_name, opts), hash|
          hash[arg_name] = Filters::Registry.build(arg_name, **opts)
        end

        non_optional_args = args_def.reject { |_key, value| value[:optional] == true }
        args_not_provided = non_optional_args.keys - given_args.keys

        args_with_default_to_add = args_def.select { |key, value| !value[:default].nil? && args_not_provided.include?(key) }
        given_args.merge!(args_with_default_to_add.map { |key, value| [key, value[:default]] }.to_h)

        missing_args = non_optional_args.keys - given_args.keys
        raise ArgumentError, "Params missing: #{missing_args}" unless missing_args.empty?

        extra_params = given_args.keys - args_def.keys
        raise ArgumentError, "Unknown params: #{extra_params}" unless extra_params.empty?

        # Validate and coerce each argument using its filter
        given_args.each do |arg_name, arg_value|
          filter = filters[arg_name]
          given_args[arg_name] = filter.process(arg_value)
        end

        # Populates all the non optional non given arguments with nil.
        not_given_args = args_def.keys - given_args.keys
        given_args.merge(not_given_args.map { |key| [key, nil] }.to_h)
      end
    end

    module Operations
      def gt(col, val) = __operation(:gt, col, val)
      def gteq(col, val) = __operation(:gteq, col, val)
      def lt(col, val) = __operation(:lt, col, val)
      def lteq(col, val) = __operation(:lteq, col, val)
      def like(col, val) = __operation(:matches, col, "%#{val}%")
      def start_like(col, val) = __operation(:matches, col, "#{val}%")
      def end_like(col, val) = __operation(:matches, col, "%#{val}")
      def __operation(op, col, val) = where(arel_table[col].send(op, val))
    end
  end

  module Scopes
    extend ActiveSupport::Concern

    included do
      @__scopes = []
    end

    class_methods do
      attr_accessor :__scopes

      def scope(name, lambda)
        __scopes << [name, lambda]
        define_method(name, &lambda)
      end
    end
  end

  # Register the legacy Boolean sentinel class now that Base is defined
  Filters::Registry.register_boolean_sentinel!
end
