# frozen_string_literal: true

module ActiveQuery
  module GUI
    class Engine < ::Rails::Engine
      isolate_namespace ActiveQuery::GUI

      initializer "active_query.gui.eager_load_queries" do
        ActiveSupport.on_load(:after_initialize) do
          query_dirs = %w[queries query_objects]

          # Standard Rails app paths
          query_dirs.each do |dir|
            path = Rails.root.join("app", dir)
            Rails.autoloaders.main.eager_load_dir(path.to_s) if path.exist?
          end

          # Packwerk / packs paths (packs/**/app/queries)
          query_dirs.each do |dir|
            Dir.glob(Rails.root.join("packs", "**", "app", dir).to_s).each do |path|
              Rails.autoloaders.main.eager_load_dir(path) if File.directory?(path)
            end
          end
        end
      end
    end
  end
end
