# frozen_string_literal: true

module DiscourseEventsIntegration
  class ConnectionUserSerializer < ApplicationSerializer
    attributes :id,
               :username
  end
end
