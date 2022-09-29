# frozen_string_literal: true

require "rails_helper"

describe DiscourseEventsIntegration::SyncManager do
  subject { DiscourseEventsIntegration::SyncManager }

  fab!(:category) { Fabricate(:category) }
  fab!(:user) { Fabricate(:user) }
  fab!(:connection) { Fabricate(:discourse_events_integration_connection, category: category, user: user) }
  fab!(:event) { Fabricate(:discourse_events_integration_event, source: connection.source) }

  it 'syncs a connection' do
    skip("Client not installed") unless DiscourseEventsIntegration::EventsSyncer.ready?

    subject.sync_connection(connection.id)

    topic = Topic.find_by(title: event.name, category_id: category.id)
    expect(topic.custom_fields[DiscourseEventsIntegration::Event::UID_TOPIC_CUSTOM_FIELD]).to eq(event.uid)
  end

  it 'syncs all syncable connections' do
    skip("Client not installed") unless DiscourseEventsIntegration::EventsSyncer.ready?

    subject.sync_all_connections

    topic = Topic.find_by(title: event.name, category_id: category.id)
    expect(topic.custom_fields[DiscourseEventsIntegration::Event::UID_TOPIC_CUSTOM_FIELD]).to eq(event.uid)
  end
end
