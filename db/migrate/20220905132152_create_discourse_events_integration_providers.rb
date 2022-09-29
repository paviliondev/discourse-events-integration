# frozen_string_literal: true

class CreateDiscourseEventsIntegrationProviders < ActiveRecord::Migration[7.0]
  def change
    create_table :discourse_events_integration_providers do |t|
      t.string    :name, null: false
      t.string    :provider_type, null: false
      t.string    :username
      t.string    :password
      t.string    :token
      t.datetime  :token_expires_at
      t.string    :client_id
      t.string    :client_secret
      t.string    :refresh_token

      t.timestamps
    end

    add_index :discourse_events_integration_providers, [:name], unique: true
  end
end
