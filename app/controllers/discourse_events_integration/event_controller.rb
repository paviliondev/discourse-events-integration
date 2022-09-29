# frozen_string_literal: true

module DiscourseEventsIntegration
  class EventController < AdminController

    PAGE_LIMIT = 30

    def index
      page = params[:page].to_i
      order = params[:order] || "start_time"
      direction = ActiveRecord::Type::Boolean.new.cast(params[:asc]) ? "ASC" : "DESC"
      offset = page * PAGE_LIMIT

      events = Event
        .includes(:source, event_connections: [:topic])
        .order("#{order} #{direction}")
        .offset(offset)
        .limit(PAGE_LIMIT)

      render_json_dump(
        page: page,
        events: serialize_data(events, EventSerializer, root: false)
      )
    end

    def destroy
      event_ids = params[:event_ids]
      destroy_topics = ActiveRecord::Type::Boolean.new.cast(params[:destroy_topics])
      result = []

      ActiveRecord::Base.transaction do
        events = Event.where(id: event_ids)

        if destroy_topics
          events.includes(:event_connections).each do |event|
            event.event_connections.each do |ec|
              PostDestroyer.new(current_user, ec.post).destroy
            end
          end
        end

        result = events.destroy_all
      end

      if result.present?
        render json: success_json.merge(destroyed_ids: result.map(&:id))
      else
        render json: failed_json
      end
    end
  end
end
