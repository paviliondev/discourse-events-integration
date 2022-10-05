# frozen_string_literal: true

module ::DiscourseEventsIntegration
  PLUGIN_NAME ||= 'discourse-events-integration'

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace DiscourseEventsIntegration
  end

  def self.base_url
    if Rails.env.development?
      "https://#{ENV["RAILS_DEVELOPMENT_HOSTS"].split(',').first}"
    else
      Discourse.base_url
    end
  end
end
