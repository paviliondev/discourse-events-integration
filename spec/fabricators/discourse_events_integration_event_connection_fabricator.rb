# frozen_string_literal: true

Fabricator(:discourse_events_integration_event_connection, from: "DiscourseEventsIntegration::EventConnection") do
  event { Fabricate(:discourse_events_integration_event) }
  connection { Fabricate(:discourse_events_integration_connection) }
  client { 'events' }
end
