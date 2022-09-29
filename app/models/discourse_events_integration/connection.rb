# frozen_string_literal: true

module DiscourseEventsIntegration
  class Connection < ActiveRecord::Base
    self.table_name = 'discourse_events_integration_connections'

    CLIENTS ||= %w(events_integration events discourse_events)

    has_many :event_connections, foreign_key: 'connection_id', class_name: 'DiscourseEventsIntegration::EventConnection', dependent: :destroy
    has_many :events, through: :event_connections, source: :event

    belongs_to :user
    belongs_to :category
    belongs_to :source, foreign_key: 'source_id', class_name: 'DiscourseEventsIntegration::Source'

    validates :client, inclusion: { in: CLIENTS, message: "%{value} is not a valid connection client" }
    validates :user, presence: true
    validates :category, presence: true
    validates :source, presence: true

    scope :to_sync, -> { where("client <> 'events_integration'") }
  end
end

# == Schema Information
#
# Table name: discourse_events_integration_connections
#
#  id          :bigint           not null, primary key
#  user_id     :bigint
#  category_id :bigint
#  source_id   :bigint           not null
#  client      :string
#  from_time   :datetime
#  to_time     :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  events_integration_connections_category_source                 (category_id,source_id) UNIQUE
#  index_discourse_events_integration_connections_on_category_id  (category_id)
#  index_discourse_events_integration_connections_on_source_id    (source_id)
#  index_discourse_events_integration_connections_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (source_id => discourse_events_integration_sources.id)
#
