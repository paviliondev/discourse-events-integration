# frozen_string_literal: true

module Jobs
  class DiscourseEventsIntegrationImportSource < ::Jobs::Base
    def execute(args)
      ::DiscourseEventsIntegration::ImportManager.import_source(args[:source_id])
    end
  end
end
