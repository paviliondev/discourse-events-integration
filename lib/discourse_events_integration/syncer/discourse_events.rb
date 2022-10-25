# frozen_string_literal: true

module DiscourseEventsIntegration
  class DiscourseEventsSyncer < DiscourseEventsIntegration::Syncer
    def self.ready?
      defined?(DiscoursePostEvent) == 'constant' &&
        DiscoursePostEvent.class == Module &&
        ::SiteSetting.calendar_enabled &&
        ::SiteSetting.discourse_post_event_enabled
    end

    def create_event_topic(event)
      post = create_event_post(event)
      post.topic
    end

    def update_event_topic(topic, event)
      # No validations or callbacks can be triggered when updating this data
      topic.update_columns(title: event.name)
      topic.first_post.update_columns(raw: post_raw(event))

      if topic.first_post.event
        topic.first_post.event.update_columns(original_starts_at: event.start_time, original_ends_at: event.end_time, url: event.url)
        topic.first_post.event.event_dates.first.update_columns(starts_at: event.start_time, ends_at: event.end_time)
      end
      topic.first_post.trigger_post_process(bypass_bump: true, priority: :low)

      topic
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
