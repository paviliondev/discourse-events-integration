# frozen_string_literal: true
class AddClientToEventsIntegrationEventConnections < ActiveRecord::Migration[7.0]
  def change
    add_column :discourse_events_integration_event_connections, :client, :string
  end
end
