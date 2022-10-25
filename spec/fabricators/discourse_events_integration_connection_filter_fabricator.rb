# frozen_string_literal: true

Fabricator(:discourse_events_integration_connection_filter, from: "DiscourseEventsIntegration::ConnectionFilter") do
  connection { Fabricate(:discourse_events_integration_connection) }
  query_column { :name }
end
