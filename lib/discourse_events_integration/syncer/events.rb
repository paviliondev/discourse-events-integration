# frozen_string_literal: true

module DiscourseEventsIntegration
  class EventsSyncer < DiscourseEventsIntegration::Syncer
    def self.ready?
      defined?(CalendarEvents) == 'constant' && CalendarEvents.class == Module
    end

    def update_events
      topics_updated = []

      synced_events.includes(event_connections: [:topic, :post]).each do |event|
        ActiveRecord::Base.transaction do
          # No validations or callbacks can be triggered when updating this data
          event.event_connections.each do |ec|
            ec.topic.update_columns(title: event.name, featured_link: event.url)
            ec.post.update_columns(raw: post_raw(event))

            ec.topic.custom_fields["event_start"] = event.start_time.to_i
            ec.topic.custom_fields["event_end"] = event.end_time.to_i
            ec.topic.save_custom_fields(true)

            topics_updated << ec.topic.id
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
              featured_link: event.url,
              custom_fields: {
                "#{Event::UID_TOPIC_CUSTOM_FIELD}": event.uid,
                "event_start": event.start_time.to_i,
                "event_end": event.end_time.to_i
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
      raw = ""
      raw += "#{event.description}" if event.description.present?
      raw
    end
  end
end

# == Events Plugin Schema
#
# Table: topic_custom_fields
#
# Fields:
#  event_start        unix datetime
#  event_end          unix datetime
