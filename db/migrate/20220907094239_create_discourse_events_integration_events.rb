# frozen_string_literal: true

class CreateDiscourseEventsIntegrationEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_events_integration_events do |t|
      t.string      :uid, null: false
      t.datetime    :start_time, null: false
      t.datetime    :end_time
      t.string      :name
      t.string      :description
      t.string      :status, default: 'published'
      t.string      :taxonomy
      t.string      :url
      t.references  :source, index: true, foreign_key: { to_table: :discourse_events_integration_sources }
      t.references  :provider, index: true, foreign_key: { to_table: :discourse_events_integration_providers }

      t.timestamps
    end

    add_index :discourse_events_integration_events, [:uid, :provider_id], unique: true, name: "integration_event_id_index"
  end
end
