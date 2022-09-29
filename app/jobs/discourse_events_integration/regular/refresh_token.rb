# frozen_string_literal: true

module Jobs
  class DiscourseEventsIntegrationRefreshToken < ::Jobs::Base
    def execute(args)
      provider = ::DiscourseEventsIntegration::Provider.find_by(id: args[:provider_id])
      return unless provider&.oauth2_type?

      provider.auth.refresh_token!
    end
  end
end
