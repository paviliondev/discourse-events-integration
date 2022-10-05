# frozen_string_literal: true
class CreateDiscourseEventsIntegrationLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_events_integration_logs do |t|
      t.integer    :level
      t.integer    :context
      t.string     :message

      t.timestamps
    end
  end
end
