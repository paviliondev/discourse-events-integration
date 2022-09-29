# frozen_string_literal: true

module DiscourseEventsIntegration
  class EventSerializer < ApplicationSerializer
    attributes :id,
               :start_time,
               :end_time,
               :name,
               :description,
               :status,
               :url,
               :created_at,
               :updated_at

    has_many :topics, serializer: BasicTopicSerializer, embed: :objects
    has_one :source, serializer: SourceSerializer, embed: :objects
  end
end
