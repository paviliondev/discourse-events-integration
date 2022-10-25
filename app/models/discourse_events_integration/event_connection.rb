# frozen_string_literal: true

module DiscourseEventsIntegration
  class EventConnection < ActiveRecord::Base
    self.table_name = 'discourse_events_integration_event_connections'

    belongs_to :connection, foreign_key: 'connection_id', class_name: 'DiscourseEventsIntegration::Connection'
    belongs_to :event, foreign_key: 'event_id', class_name: 'DiscourseEventsIntegration::Event'
    belongs_to :topic
    belongs_to :post
  end
end

# == Schema Information
#
# Table name: discourse_events_integration_event_connections
#
#  id            :bigint           not null, primary key
#  event_id      :bigint           not null
#  connection_id :bigint           not null
#  topic_id      :bigint
#  post_id       :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  series_id     :string
#
# Indexes
#
#  discourse_events_integration_event_connections_event  (event_id)
#
# Foreign Keys
#
#  fk_rails_...  (connection_id => discourse_events_integration_connections.id)
#  fk_rails_...  (event_id => discourse_events_integration_events.id)
#
