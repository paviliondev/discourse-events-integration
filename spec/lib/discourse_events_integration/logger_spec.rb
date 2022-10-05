# frozen_string_literal: true

require "rails_helper"

describe DiscourseEventsIntegration::Logger do
  subject { DiscourseEventsIntegration::Logger }

  it 'creates logs' do
    subject.new(:sync).log(:info, "Test log")

    expect(DiscourseEventsIntegration::Log.exists?(
      level: "info",
      context: "sync",
      message: "Test log"
    )).to eq(true)
  end
end
