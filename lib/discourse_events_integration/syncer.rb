# frozen_string_literal: true

module DiscourseEventsIntegration
  class Syncer
    attr_reader :user,
                :connection

    attr_accessor :opts

    def initialize(user, connection)
      raise ArgumentError.new("Must pass a valid connection") unless connection

      @user = user
      @connection = connection
    end

    def sync(_opts = {})
      @opts = _opts

      updated_topics = update_events
      created_topics = create_events

      {
        created_topics: created_topics,
        updated_topics: updated_topics
      }
    end

    def update_events
    end

    def create_events
    end

    def synced_events
      source_events.where("id IN (#{event_connections_sql})")
    end

    def unsynced_events
      source_events.where("id NOT IN (#{event_connections_sql})")
    end

    def event_connections_sql
      "SELECT event_id FROM discourse_events_integration_event_connections WHERE connection_id = #{connection.id}"
    end

    def source_events
      @source_events ||= Event.where("discourse_events_integration_events.source_id = #{connection.source.id}")
    end
  end
end
