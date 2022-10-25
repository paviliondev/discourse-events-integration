# frozen_string_literal: true

require "rails_helper"

describe DiscourseEventsIntegration::SyncManager do
  subject { DiscourseEventsIntegration::SyncManager }

  fab!(:source) { Fabricate(:discourse_events_integration_source) }
  fab!(:category) { Fabricate(:category) }
  fab!(:user) { Fabricate(:user) }
  fab!(:connection) { Fabricate(:discourse_events_integration_connection, source: source, category: category, user: user) }
  fab!(:event) { Fabricate(:discourse_events_integration_event, source: source) }

  it 'syncs a connection' do
    skip("Client not installed") unless DiscourseEventsIntegration::EventsSyncer.ready?

    subject.sync_connection(connection.id)

    topic = Topic.find_by(title: event.name, category_id: category.id)
    expect(topic.id).to eq(event.topics.first.id)
  end

  it 'syncs all syncable connections' do
    skip("Client not installed") unless DiscourseEventsIntegration::EventsSyncer.ready?

    subject.sync_all_connections

    topic = Topic.find_by(title: event.name, category_id: category.id)
    expect(topic.id).to eq(event.topics.first.id)
  end

  context "with event series" do
    fab!(:event1) { Fabricate(:discourse_events_integration_event, source: source, series_id: "ABC", occurrence_id: "1") }
    fab!(:event2) { Fabricate(:discourse_events_integration_event, source: source, series_id: "ABC", occurrence_id: "2") }

    before do
      DiscourseEventsIntegration::Source.any_instance.stubs(:supports_series).returns(true)
      SiteSetting.split_event_series_into_different_topics = false
    end

    it "syncs series events" do
      freeze_time

      first_start_time = 2.days.from_now
      second_start_time = 4.days.from_now

      event1.start_time = first_start_time
      event1.save
      event2.start_time = second_start_time
      event2.save

      result = subject.sync_connection(connection.id)
      expect(result[:created_topics].size).to eq(2)
      expect(result[:updated_topics].size).to eq(0)
      expect(result[:created_topics]).to include(event1.reload.topics.first.id)

      freeze_time(2.days.from_now + 1.hour)

      result = subject.sync_connection(connection.id)
      expect(result[:created_topics].size).to eq(0)
      expect(result[:updated_topics].size).to eq(2)
      expect(result[:updated_topics]).to include(event2.reload.topics.first.id)
    end
  end
end
