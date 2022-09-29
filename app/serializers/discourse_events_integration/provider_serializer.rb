# frozen_string_literal: true

module DiscourseEventsIntegration
  class ProviderSerializer < ApplicationSerializer
    attributes :id,
               :name,
               :provider_type,
               :username,
               :password,
               :token,
               :client_id,
               :client_secret,
               :authenticated

    def authenticated
      object.authenticated?
    end
  end
end
