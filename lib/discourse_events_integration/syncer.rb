# frozen_string_literal: true

module DiscourseEventsIntegration
  class Syncer

    EVENT_SERIES_ID_FIELD = "event_series_id"

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

    ## Implemented by children

    def create_event_topic(event)
    end

    def update_event_topic(topic, event)
    end

    def post_raw(event)
    end

    ##

    def sync(_opts = {})
      @opts = _opts

      updated_topics = update_events
      created_topics = create_events

      if one_topic_per_series
        updated_series_topics = update_series_events_topics
        created_topics += updated_series_topics[:created_topics]
        updated_topics += updated_series_topics[:updated_topics]
      end

      {
        created_topics: created_topics,
        updated_topics: updated_topics
      }
    end

    def update_events
      topics_updated = []

      synced_events.includes(event_connections: [:topic, :post]).each do |event|
        ActiveRecord::Base.transaction do
          event.event_connections.each do |ec|
            topics_updated << _update_event_topic(ec.topic, event)
          end
        end
      end

      topics_updated
    end

    def create_events
      topics_created = []

      unsynced_events.each do |event|
        ActiveRecord::Base.transaction do
          topics_created << _create_event_topic(event)
        end
      end

      topics_created
    end

    def update_series_events_topics
      topics_updated = []
      topics_created = []

      series_events.each do |event|
        topics = event.series_events_topics

        ActiveRecord::Base.transaction do
          if topics.exists?
            topic = topics.first
            create_event_connection(event, topic)
            topics_updated << _update_event_topic(topic, event)
          else
            topics_created << _create_event_topic(event)
          end
        end
      end

      {
        updated_topics: topics_updated,
        created_topics: topics_created
      }
    end

    def synced_events
      standard_events.where("id IN (#{event_connections_sql})")
    end

    def unsynced_events
      standard_events.where("id NOT IN (#{event_connections_sql})")
    end

    def event_connections_sql
      "SELECT event_id FROM discourse_events_integration_event_connections WHERE connection_id = #{connection.id}"
    end

    def source_events
      @source_events ||= begin
        events = Event.where("discourse_events_integration_events.source_id = #{connection.source.id}")
        connection.filters.each do |filter|
          events = events.where("#{filter.sql_column} #{filter.sql_operator} ?", filter.sql_value)
        end
        events
      end
    end

    def standard_events
      @standard_events ||= begin
        events = source_events
        if one_topic_per_series
          events = events.where("discourse_events_integration_events.series_id IS NULL")
        end
        events
      end
    end

    def series_events
      @series_events ||= begin
        source_events
          .select("DISTINCT ON (series_id) discourse_events_integration_events.*")
          .where("discourse_events_integration_events.series_id IS NOT NULL AND discourse_events_integration_events.start_time > '#{Time.now.to_s}'")
          .order("discourse_events_integration_events.series_id, discourse_events_integration_events.start_time ASC")
      end
    end

    def log(type, message)
      logger.send(type.to_s, message)
    end

    def create_event_post(event, topic_opts = {})
      topic_opts = {
        title: event.name
      }.merge(topic_opts)

      if connection.category_id
        topic_opts[:category] = connection.category.id
      end

      PostCreator.create!(
        user,
        topic_opts: topic_opts,
        raw: post_raw(event),
        skip_validations: true
      )
    end

    def create_event_connection(event, topic)
      params = {
        event_id: event.id,
        connection_id: connection.id,
        topic_id: topic.id,
        post_id: topic.first_post.id
      }

      if event.series_id
        params[:series_id] = event.series_id
      end

      EventConnection.create!(params)
    end

    def one_topic_per_series
      connection.source.supports_series && !SiteSetting.split_event_series_into_different_topics
    end

    def _create_event_topic(event)
      topic = create_event_topic(event)
      raise ActiveRecord::Rollback unless topic.present?
      create_event_connection(event, topic)
      topic.id
    end

    def _update_event_topic(topic, event)
      topic = update_event_topic(topic, event)
      raise ActiveRecord::Rollback unless topic.present?
      topic.id
    end
  end
end
