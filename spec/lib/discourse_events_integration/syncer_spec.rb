# frozen_string_literal: true

require "rails_helper"

describe DiscourseEventsIntegration::Syncer do
  subject { DiscourseEventsIntegration::Syncer }

  fab!(:source) { Fabricate(:discourse_events_integration_source) }
  fab!(:category) { Fabricate(:category) }
  fab!(:user) { Fabricate(:user) }
  fab!(:connection) { Fabricate(:discourse_events_integration_connection, source: source, category: category, user: user) }
  fab!(:event1) { Fabricate(:discourse_events_integration_event, source: source, series_id: "ABC", occurrence_id: "1") }
  fab!(:event2) { Fabricate(:discourse_events_integration_event, source: source, series_id: "ABC", occurrence_id: "2") }

  it 'returns ids of created and updated topics' do
    syncer = subject.new(user, connection)
    syncer.stubs(:create_events).returns([1])
    syncer.stubs(:update_events).returns([2, 3])
    result = syncer.sync

    expect(result).to eq(
      {
        created_topics: [1],
        updated_topics: [2, 3]
      }
    )
  end

  context "with event series" do
    it "sources all events if source does not support event series" do
      connection.source.stubs(:supports_series).returns(false)

      syncer = subject.new(user, connection)
      expect(syncer.standard_events.size).to eq(2)
    end

    context "when source supports event series" do
      before do
        connection.source.stubs(:supports_series).returns(true)
      end

      it "sources all events if split_event_series_into_different_topics is enabled" do
        SiteSetting.split_event_series_into_different_topics = true

        syncer = subject.new(user, connection)
        expect(syncer.standard_events.size).to eq(2)
      end

      it "sources series events" do
        freeze_time

        first_start_time = 2.days.from_now
        second_start_time = 4.days.from_now

        event1.start_time = first_start_time
        event1.save
        event2.start_time = second_start_time
        event2.save

        syncer = subject.new(user, connection)
        expect(syncer.series_events.size).to eq(1)
        expect(syncer.series_events.first.start_time).to be_within(1.second).of(first_start_time)

        freeze_time(2.days.from_now + 1.hour)

        syncer = subject.new(user, connection)
        expect(syncer.series_events.size).to eq(1)
        expect(syncer.series_events.first.start_time).to be_within(1.second).of(second_start_time)
      end
    end
  end

  context "with filters" do
    fab!(:filter1) { Fabricate(:discourse_events_integration_connection_filter, connection: connection, query_value: event2.name) }

    it "filters events" do
      syncer = subject.new(user, connection)
      expect(syncer.standard_events.size).to eq(1)
      expect(syncer.standard_events.first.name).to eq(event2.name)
    end
  end
end
