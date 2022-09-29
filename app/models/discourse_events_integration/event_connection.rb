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
