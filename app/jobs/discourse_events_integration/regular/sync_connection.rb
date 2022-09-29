# frozen_string_literal: true

module Jobs
  class DiscourseEventsIntegrationSyncConnection < ::Jobs::Base
    def execute(args)
      ::DiscourseEventsIntegration::SyncManager.sync_connection(args[:connection_id])
    end
  end
end
