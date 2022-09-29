# frozen_string_literal: true

Fabricator(:discourse_events_integration_connection, from: "DiscourseEventsIntegration::Connection") do
  client { 'events' }
  source { Fabricate(:discourse_events_integration_source) }
  user { Fabricate(:user) }
  category { Fabricate(:category) }
end
