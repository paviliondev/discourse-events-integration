# frozen_string_literal: true

Fabricator(:discourse_events_integration_provider, from: "DiscourseEventsIntegration::Provider") do
  name { sequence(:name) { |i| "provider_#{i}" } }
  provider_type { 'developer' }
end
