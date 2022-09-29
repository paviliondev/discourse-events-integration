# frozen_string_literal: true

module DiscourseEventsIntegration
  class Event < ActiveRecord::Base
    self.table_name = 'discourse_events_integration_events'

    UID_TOPIC_CUSTOM_FIELD ||= 'event_uid'

    has_many :event_connections, foreign_key: 'event_id', class_name: 'DiscourseEventsIntegration::EventConnection', dependent: :destroy
    has_many :connections, through: :event_connections, source: :connection
    has_many :topics, through: :event_connections

    belongs_to :source, foreign_key: 'source_id', class_name: 'DiscourseEventsIntegration::Source'
    belongs_to :provider, foreign_key: 'provider_id', class_name: 'DiscourseEventsIntegration::Provider'

    validates :status, inclusion: { in: %w(draft published cancelled), message: "%{value} is not a valid event status" }
  end
end

# == Schema Information
#
# Table name: discourse_events_integration_events
#
#  id          :bigint           not null, primary key
#  uid         :string           not null
#  start_time  :datetime         not null
#  end_time    :datetime
#  timezone    :string
#  name        :string
#  description :string
#  status      :string           default("published")
#  taxonomy    :string
#  url         :string
#  source_id   :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_discourse_events_integration_events_on_post_id    (post_id)
#  index_discourse_events_integration_events_on_source_id  (source_id)
#  index_discourse_events_integration_events_on_topic_id   (topic_id)
#  index_discourse_events_integration_events_on_uid        (uid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (source_id => discourse_events_integration_sources.id)
#
