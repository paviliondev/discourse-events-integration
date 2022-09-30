# frozen_string_literal: true

module DiscourseEventsIntegration
  class Source < ActiveRecord::Base
    self.table_name = 'discourse_events_integration_sources'

    SOURCE_OPTIONS ||= {
      icalendar: {
        'uri': URI.regexp
      },
      eventbrite: {
        'organization_id': /\d/
      },
      meetup: {
        'group_urlname': /[a-z]/
      },
      humanitix: {
      },
      eventzilla: {
      }
    }

    belongs_to :provider, foreign_key: 'provider_id', class_name: 'DiscourseEventsIntegration::Provider'

    has_many :events, foreign_key: 'source_id', class_name: 'DiscourseEventsIntegration::Event'
    has_many :connections, foreign_key: 'source_id', class_name: 'DiscourseEventsIntegration::Connection', dependent: :destroy

    validates_format_of :name, with: /\A[a-z0-9\_]+\Z/i
    validates :provider, presence: true
    validate :valid_source_options?

    def ready?
      provider.authenticated?
    end

    def source_options_hash
      if source_options.present?
        JSON.parse(source_options).symbolize_keys
      else
        {}
      end
    end

    private

    def valid_source_options?
      return true if self.source_options.nil?

      unless valid_json?(self.source_options)
        begin
          self.source_options = self.source_options.to_json
        rescue JSON::ParserError => e
          errors.add(:source_options, "are not valid")
        end
      end
      return false if errors.present?

      invalid = invalid_options(self.source_options_hash, SOURCE_OPTIONS[self.provider.provider_type.to_sym])
      errors.add(:source_options, "invalid: #{invalid.join(',')}") if invalid.any?
    end

    def invalid_options(opts, valid_options)
      opts.reduce([]) do |result, (key, value)|
        match = valid_options[key.to_sym]
        result << key if !match || value !~ match
        result
      end
    end

    def valid_json?(json)
      JSON.parse(json)
      true
    rescue JSON::ParserError => e
      false
    end
  end
end

# == Schema Information
#
# Table name: discourse_events_integration_sources
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  provider_id   :bigint           not null
#  source_options :json
#  from_time     :datetime
#  to_time       :datetime
#  status        :string
#  taxonomy      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_discourse_events_integration_sources_on_name         (name) UNIQUE
#  index_discourse_events_integration_sources_on_provider_id  (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => discourse_events_integration_providers.id)
#
