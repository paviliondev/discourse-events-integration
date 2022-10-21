# frozen_string_literal: true

module DiscourseEventsIntegration
  class Syncer
    attr_reader :user,
                :connection,
                :logger

    attr_accessor :opts

    def initialize(user, connection)
      raise ArgumentError.new("Must pass a valid connection") unless connection

      @user = user
      @connection = connection
      @logger = Logger.new(:sync)
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
      @source_events ||= begin
        events = Event.where("discourse_events_integration_events.source_id = #{connection.source.id}")

        if connection.source.supports_series && !SiteSetting.split_event_series_into_different_topics
          events = events
            .select("DISTINCT ON (series_id) discourse_events_integration_events.*")
            .where("discourse_events_integration_events.start_time > now()")
            .order("series_id, discourse_events_integration_events.start_time ASC")
        end

        events
      end
    end

    def log(type, message)
      logger.send(type.to_s, message)
    end
  end
end
