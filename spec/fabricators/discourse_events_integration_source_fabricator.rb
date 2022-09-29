# frozen_string_literal: true

Fabricator(:discourse_events_integration_source, from: "DiscourseEventsIntegration::Source") do
  name { sequence(:name) { |i| "source_#{i}" } }
  provider { Fabricate(:discourse_events_integration_provider) }
  taxonomy { 'cats' }
  status { 'published' }
end
