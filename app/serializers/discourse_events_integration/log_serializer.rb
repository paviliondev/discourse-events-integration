# frozen_string_literal: true

module DiscourseEventsIntegration
  class LogSerializer < ApplicationSerializer
    attributes :id,
               :level,
               :context,
               :message,
               :created_at
  end
end
