# frozen_string_literal: true
class AddRecurrenceToDiscourseEventsIntegrationEvents < ActiveRecord::Migration[7.0]
  def change
    add_column :discourse_events_integration_events, :series_id, :string
    add_column :discourse_events_integration_events, :occurrence_id, :string
  end
end
