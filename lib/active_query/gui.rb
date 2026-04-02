# frozen_string_literal: true

module ActiveQuery
  module GUI
  end
end

require "active_query/gui/engine" if defined?(Rails::Engine)
