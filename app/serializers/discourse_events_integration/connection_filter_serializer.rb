# frozen_string_literal: true

module DiscourseEventsIntegration
  class ConnectionFilterSerializer < ApplicationSerializer
    attributes :id,
               :query_column,
               :query_value
  end
end
