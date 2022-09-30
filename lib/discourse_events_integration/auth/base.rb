# frozen_string_literal: true

module DiscourseEventsIntegration
  module Auth
    class Base
      attr_reader :provider

      def initialize(provider_id)
        @provider = Provider.find(provider_id)
      end

      def authorization_url
        raise NotImplementedError
      end

      def request_token(code)
        raise NotImplementedError
      end

      def refresh_token!
        raise NotImplementedError
      end
    end
  end
end
