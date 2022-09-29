# frozen_string_literal: true

module Jobs
  class DiscourseEventsIntegration::UpateEvents < ::Jobs::Scheduled
    every SiteSetting.update_events_automatically_period_mins.minutes

    def execute(args)
      if should_update?
        DiscourseEventsIntegration::ImportManager.import_all_sources
        DiscourseEventsIntegration::SyncManager.sync_all_connections
      end
    end

    def should_update?
      return false if Rails.env.development? && ENV["UPDATE_EVENTS"].nil?
      SiteSetting.update_events_automatically?
    end
  end
end
