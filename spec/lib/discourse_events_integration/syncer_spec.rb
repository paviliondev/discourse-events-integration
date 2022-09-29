# frozen_string_literal: true

require "rails_helper"

describe DiscourseEventsIntegration::Syncer do
  subject { DiscourseEventsIntegration::Syncer }

  fab!(:connection) { Fabricate(:discourse_events_integration_connection) }
  fab!(:user) { Fabricate(:user) }

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
end
