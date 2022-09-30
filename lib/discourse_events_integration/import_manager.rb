# frozen_string_literal: true

module DiscourseEventsIntegration
  class ImportManager
    attr_reader :provider,
                :source

    def initialize(provider, source)
      @provider = provider
      @source = source

      ::OmniEvent::Builder.new do
        provider provider.provider_type, provider.options
      end
    end

    def import(opts = {})
      events = ::OmniEvent.list_events(provider.provider_type, opts).map do |e|
        data = e.data.to_h.with_indifferent_access

        data[:uid] = e.metadata.uid
        data[:status] = "published" unless data[:status].present?

        if source
          data[:source_id] = source.id
          data[:provider_id] = source.provider.id
        end

        data
      end

      events_count = 0
      created_count = 0
      updated_count = 0

      if events.present?
        result = Event.upsert_all(events,
          unique_by: %i[ uid provider_id ],
          record_timestamps: true,
          returning: Arel.sql("(xmax = 0) AS inserted")
        )
        events_count = events.size
        created_count = result.rows.map { |r| r[0] }.tally[true].to_i
        updated_count = events_count - created_count
      end

      if source
        Log.create(
          log_type: 'import',
          message: I18n.t("log.import_finished",
            source_name: source.name,
            events_count: events_count,
            created_count: created_count,
            updated_count: updated_count,
          )
        )
      end

      {
        events_count: events_count,
        created_count: created_count,
        updated_count: updated_count
      }
    end

    def self.import_source(source_id)
      source = Source.find_by(id: source_id)
      return unless source.present?

      manager = self.new(source.provider, source)
      manager.import(
        source.source_options_hash.merge(
          from_time: source.from_time,
          to_time: source.to_time
        )
      )
    end

    def self.import_all_sources
      Source.all.each do |source|
        if source.ready?
          manager = self.new(source.provider, source)
          manager.import(
            source.source_options_hash.merge(
              from_time: source.from_time,
              to_time: source.to_time
            )
          )
        end
      end
    end
  end
end
