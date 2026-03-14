# frozen_string_literal: true

module ActiveQuery
  module GUI
    class Engine < ::Rails::Engine
      isolate_namespace ActiveQuery::GUI

      initializer "active_query.gui.eager_load_queries" do
        ActiveSupport.on_load(:after_initialize) do
          %w[queries query_objects].each do |dir|
            path = Rails.root.join("app", dir)
            Rails.autoloaders.main.eager_load_dir(path.to_s) if path.exist?
          end
        end
      end
    end
  end
end
