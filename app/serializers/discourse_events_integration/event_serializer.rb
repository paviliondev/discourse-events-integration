# frozen_string_literal: true

module DiscourseEventsIntegration
  class EventSerializer < BasicEventSerializer
    has_many :topics, serializer: BasicTopicSerializer, embed: :objects
    has_one :source, serializer: SourceSerializer, embed: :objects
  end
end
