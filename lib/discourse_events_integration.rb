# frozen_string_literal: true

module ::DiscourseEventsIntegration
  PLUGIN_NAME ||= 'discourse-events-integration'

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseEventsIntegration
  end
end
