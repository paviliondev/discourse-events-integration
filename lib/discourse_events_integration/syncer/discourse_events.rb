# frozen_string_literal: true

module DiscourseEventsIntegration
  class DiscourseEventsSyncer < DiscourseEventsIntegration::Syncer
    def self.ready?
      defined?(DiscoursePostEvent) == 'constant' &&
        DiscoursePostEvent.class == Module &&
        ::SiteSetting.calendar_enabled &&
        ::SiteSetting.discourse_post_event_enabled
    end

    def update_events
      topics_updated = []

      synced_events.includes(event_connections: [:topic, :post]).each do |event|
        ActiveRecord::Base.transaction do
          # No validations or callbacks can be triggered when updating this data
          event.event_connections.each do |ec|
            ec.topic.update_columns(title: event.name)
            ec.post.update_columns(raw: post_raw(event))

            if ec.post.event
              ec.post.event.update_columns(original_starts_at: event.start_time, original_ends_at: event.end_time, url: event.url)
              ec.post.event.event_dates.first.update_columns(starts_at: event.start_time, ends_at: event.end_time)
            end
            ec.post.trigger_post_process(bypass_bump: true, priority: :low)

            topics_updated << ec.topic_id
          end
        end
      end

      topics_updated
    end

    def create_events
      topics_created = []

      unsynced_events.each do |event|
        ActiveRecord::Base.transaction do
          post = PostCreator.create!(
            user,
            topic_opts: {
              title: event.name,
              category: connection.category.id,
              custom_fields: {
                "#{Event::UID_TOPIC_CUSTOM_FIELD}": event.uid
              }
            },
            raw: post_raw(event),
            skip_validations: true
          )

          raise ActiveRecord::Rollback unless post.present?

          EventConnection.create!(
            event_id: event.id,
            connection_id: connection.id,
            topic_id: post.topic_id,
            post_id: post.id
          )

          topics_created << post.topic_id
        end
      end

      topics_created
    end

    def post_raw(event)
      raw = "[event start=\"#{event.start_time}\" end=\"#{event.end_time}\" url=\"#{event.url}\"]\n[/event]"
      raw += "\n#{event.description}" if event.description.present?
      raw
    end
  end
end

# == Discourse Events Plugin Schema
#
# Table: discourse_calendar_post_events
#
# Fields:
#  status       0
#  name         string
#
# Table: discourse_calendar_post_event_dates
#
# Fields:
#  event_id     integer
#  starts_at    datetime
#  ends_at      datetime
