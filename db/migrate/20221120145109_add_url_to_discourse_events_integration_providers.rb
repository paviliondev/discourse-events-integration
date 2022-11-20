# frozen_string_literal: true
class AddUrlToDiscourseEventsIntegrationProviders < ActiveRecord::Migration[7.0]
  def change
    add_column :discourse_events_integration_providers, :url, :string
  end
end
