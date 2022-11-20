# frozen_string_literal: true
# name: discourse-events-integration
# about: Integrate events into Discourse
# version: 0.1.0.beta
# authors: Angus McLeod
# url: https://github.com/paviliondev/discourse-events-integration
# contact_emails: development@pavilion.tech

register_asset 'stylesheets/common/common.scss'
enabled_site_setting :events_integration_enabled

gem "uuidtools", "2.2.0"
gem "iso-639", "0.3.5"
gem "ice_cube", "0.16.4"
gem "icalendar", "2.8.0"
gem "icalendar-recurrence", "1.1.3"
gem "date", "3.2.2"
gem "time", "0.2.0"
gem "stringio", "3.0.2"
gem "open-uri", "0.2.0"
gem "omnievent", "0.1.0.pre3", require_name: "omnievent"
gem "omnievent-icalendar", "0.1.0.pre2", require_name: "omnievent/icalendar"
gem "omnievent-api", "0.1.0.pre2", require_name: "omnievent/api"
gem "omnievent-eventbrite", "0.1.0.pre2", require_name: "omnievent/eventbrite"
gem "omnievent-eventzilla", "0.1.0.pre2", require_name: "omnievent/eventzilla"
gem "omnievent-meetup", "0.1.0.pre1", require_name: "omnievent/meetup"

register_svg_icon "fingerprint"
register_svg_icon "save"

after_initialize do
  %w[
    ../lib/discourse_events_integration.rb
    ../lib/discourse_events_integration/logger.rb
    ../lib/discourse_events_integration/import_manager.rb
    ../lib/discourse_events_integration/sync_manager.rb
    ../lib/discourse_events_integration/syncer.rb
    ../lib/discourse_events_integration/syncer/discourse_events.rb
    ../lib/discourse_events_integration/syncer/events.rb
    ../lib/discourse_events_integration/auth/base.rb
    ../lib/discourse_events_integration/auth/meetup.rb
    ../app/models/discourse_events_integration/connection_filter.rb
    ../app/models/discourse_events_integration/connection.rb
    ../app/models/discourse_events_integration/event.rb
    ../app/models/discourse_events_integration/event_connection.rb
    ../app/models/discourse_events_integration/log.rb
    ../app/models/discourse_events_integration/provider.rb
    ../app/models/discourse_events_integration/source.rb
    ../app/jobs/discourse_events_integration/scheduled/update_events.rb
    ../app/jobs/discourse_events_integration/regular/import_source.rb
    ../app/jobs/discourse_events_integration/regular/sync_connection.rb
    ../app/jobs/discourse_events_integration/regular/refresh_token.rb
    ../app/controllers/discourse_events_integration/admin_controller.rb
    ../app/controllers/discourse_events_integration/connection_controller.rb
    ../app/controllers/discourse_events_integration/event_controller.rb
    ../app/controllers/discourse_events_integration/log_controller.rb
    ../app/controllers/discourse_events_integration/provider_controller.rb
    ../app/controllers/discourse_events_integration/source_controller.rb
    ../app/serializers/discourse_events_integration/connection_user_serializer.rb
    ../app/serializers/discourse_events_integration/connection_filter_serializer.rb
    ../app/serializers/discourse_events_integration/connection_serializer.rb
    ../app/serializers/discourse_events_integration/source_serializer.rb
    ../app/serializers/discourse_events_integration/basic_event_serializer.rb
    ../app/serializers/discourse_events_integration/event_serializer.rb
    ../app/serializers/discourse_events_integration/post_event_serializer.rb
    ../app/serializers/discourse_events_integration/log_serializer.rb
    ../app/serializers/discourse_events_integration/provider_serializer.rb
    ../config/routes.rb
    ../extensions/guardian.rb
  ].each { |path| load File.expand_path(path, __FILE__) }

  Post.has_one :event_connection, class_name: 'DiscourseEventsIntegration::EventConnection', dependent: :destroy
  Guardian.prepend EventsIntegrationGuardianExtension

  TopicView.attr_writer :posts
  TopicView.on_preload do |topic_view|
    if SiteSetting.events_integration_enabled
      topic_view.posts = topic_view.posts.includes({ event_connection: :event })
    end
  end

  # The discourse-calendar plugin uses "event" on the post model
  add_to_serializer(:post, :integration_event) do
    DiscourseEventsIntegration::PostEventSerializer.new(object.event_connection.event, scope: scope, root: false).as_json
  end
  add_to_serializer(:post, :include_integration_event?) do
    SiteSetting.events_integration_enabled && object.event_connection.present?
  end

  add_to_class(:guardian, :can_manage_events?) do
    return false unless SiteSetting.events_integration_enabled

    is_admin? || (
      SiteSetting.allow_moderator_event_management &&
      is_staff?
    )
  end

  add_to_serializer(:current_user, :can_manage_events) do
    scope.can_manage_events?
  end
end
