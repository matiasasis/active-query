# frozen_string_literal: true

module ActiveQuery
  module GUI
    class Engine < ::Rails::Engine
      isolate_namespace ActiveQuery::GUI

      initializer "active_query.gui.eager_load_queries" do
        ActiveSupport.on_load(:after_initialize) do
          queries_path = Rails.root.join("app", "queries")
          Rails.autoloaders.main.eager_load_dir(queries_path.to_s) if queries_path.exist?
        end
      end
    end
  end
end
