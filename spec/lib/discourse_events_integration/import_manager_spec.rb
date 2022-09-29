# frozen_string_literal: true

require "rails_helper"

describe DiscourseEventsIntegration::ImportManager do
  subject { DiscourseEventsIntegration::ImportManager }
  fab!(:provider) { Fabricate(:discourse_events_integration_provider) }
  fab!(:source) { Fabricate(:discourse_events_integration_source) }
  let(:raw_data) { OmniEvent::Strategies::Developer.raw_data }

  def event_uids
    OmniEvent::Strategies::Developer.raw_data["events"].map do |event|
      event["id"]
    end
  end

  it "imports a source" do
    subject.import_source(source.id)
    events = DiscourseEventsIntegration::Event.all
    expect(events.map(&:uid)).to match_array(event_uids)
  end

  it 'imports all active sources' do
    subject.import_all_sources

    events = DiscourseEventsIntegration::Event.all
    expect(events.size).to eq(2)
    expect(events.first.uid).to eq(event_uids.first)
    expect(events.second.uid).to eq(event_uids.second)
  end

  it 'logs imports' do
    importer = subject.new(provider, source)
    importer.import

    expect(DiscourseEventsIntegration::Log.all.first.message).to eq(
      I18n.t('log.import_finished',
        source_name: source.name,
        events_count: 2,
        created_count: 2,
        updated_count: 0
      )
    )
  end
end
