# frozen_string_literal: true

require 'active_record'
require 'active_support'
require 'active_support/concern'
require_relative 'active_query/version'
require_relative 'active_query/resolver'
require_relative 'active_record_relation_extensions'

module ActiveQuery
  module Base
    extend ::ActiveSupport::Concern

    class Boolean
      def self.to_s = 'Boolean'
      def self.inspect = 'Boolean'
    end

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
          relation = relation.extending(scopes_module_name.constantize) if const_defined?(scopes_module_name)
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

        non_optional_args = args_def.reject { |key, value| value[:optional] == true }
        args_not_provided = non_optional_args.keys - given_args.keys

        args_with_default_to_add = args_def.select { |key, value| value[:default].present? && args_not_provided.include?(key) }
        given_args.merge!(args_with_default_to_add.map { |key, value| [key, value[:default]] }.to_h)

        missing_args = non_optional_args.keys - given_args.keys
        raise ArgumentError, "Params missing: #{missing_args}" unless missing_args.empty?

        extra_params = given_args.keys - args_def.keys
        raise ArgumentError, "Unknown params: #{extra_params}" unless extra_params.empty?

        given_args.each do |given_arg_name, given_arg_value|
          given_arg_config = args_def[given_arg_name]
          given_arg_type = given_arg_config[:type]

          if given_arg_config[:coerce]
            given_args[given_arg_name] = given_arg_config[:coerce].call(given_arg_value)
            given_arg_value = given_args[given_arg_name]
          elsif ActiveQuery::TypeRegistry.coercer?(given_arg_type)
            given_args[given_arg_name] = ActiveQuery::TypeRegistry.coerce(given_arg_type, given_arg_value)
            given_arg_value = given_args[given_arg_name]
          end

          unless ActiveQuery::TypeRegistry.valid?(given_arg_type, given_arg_value)
            raise ArgumentError, ":#{given_arg_name} must be of type #{given_arg_type}"
          end
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

  require_relative 'active_query/type_registry'
  TypeRegistry.register(Base::Boolean, validator: ->(val) { val == true || val == false })

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
end
