# frozen_string_literal: true

module DiscourseEventsIntegration
  class Event < ActiveRecord::Base
    self.table_name = 'discourse_events_integration_events'

    has_many :event_connections, foreign_key: 'event_id', class_name: 'DiscourseEventsIntegration::EventConnection', dependent: :destroy
    has_many :connections, through: :event_connections, source: :connection
    has_many :topics, through: :event_connections

    has_many :series_events, primary_key: "series_id", foreign_key: 'series_id', class_name: 'DiscourseEventsIntegration::EventConnection'
    has_many :series_events_topics, through: :series_events, source: :topic

    belongs_to :source, foreign_key: 'source_id', class_name: 'DiscourseEventsIntegration::Source'
    belongs_to :provider, foreign_key: 'provider_id', class_name: 'DiscourseEventsIntegration::Provider'

    validates :status, inclusion: { in: %w(draft published cancelled), message: "%{value} is not a valid event status" }
  end
end

# == Schema Information
#
# Table name: discourse_events_integration_events
#
#  id            :bigint           not null, primary key
#  uid           :string           not null
#  start_time    :datetime         not null
#  end_time      :datetime
#  name          :string
#  description   :string
#  status        :string           default("published")
#  taxonomy      :string
#  url           :string
#  source_id     :bigint
#  provider_id   :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  series_id     :string
#  occurrence_id :string
#
# Indexes
#
#  index_discourse_events_integration_events_on_provider_id  (provider_id)
#  index_discourse_events_integration_events_on_source_id    (source_id)
#  integration_event_id_index                                (uid,provider_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => discourse_events_integration_providers.id)
#  fk_rails_...  (source_id => discourse_events_integration_sources.id)
#
