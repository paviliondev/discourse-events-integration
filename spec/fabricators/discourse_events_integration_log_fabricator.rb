# frozen_string_literal: true

Fabricator(:discourse_events_integration_log, from: "DiscourseEventsIntegration::Log") do
  message { sequence(:message) { |i| "Log #{i}" } }
end
