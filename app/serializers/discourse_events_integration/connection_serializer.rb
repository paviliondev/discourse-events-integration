# frozen_string_literal: true

module DiscourseEventsIntegration
  class ConnectionSerializer < ApplicationSerializer
    attributes :id,
               :user,
               :category_id,
               :source_id,
               :client

    has_many :filters, serializer: ConnectionFilterSerializer, embed: :objects

    def user
      ConnectionUserSerializer.new(object.user, root: false).as_json
    end
  end
end
