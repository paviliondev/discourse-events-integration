# frozen_string_literal: true

module DiscourseEventsIntegration
  class LogSerializer < ApplicationSerializer
    attributes :id,
               :log_type,
               :message,
               :created_at
  end
end
