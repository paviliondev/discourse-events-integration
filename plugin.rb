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
    ../app/models/discourse_events_integration/event_connection.rb
    ../app/models/discourse_events_integration/connection.rb
    ../app/models/discourse_events_integration/event.rb
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
    ../app/serializers/discourse_events_integration/connection_serializer.rb
    ../app/serializers/discourse_events_integration/connection_user_serializer.rb
    ../app/serializers/discourse_events_integration/source_serializer.rb
    ../app/serializers/discourse_events_integration/event_serializer.rb
    ../app/serializers/discourse_events_integration/log_serializer.rb
    ../app/serializers/discourse_events_integration/provider_serializer.rb
    ../config/routes.rb
  ].each { |path| load File.expand_path(path, __FILE__) }
end
