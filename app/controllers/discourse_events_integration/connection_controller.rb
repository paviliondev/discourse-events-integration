# frozen_string_literal: true

module DiscourseEventsIntegration
  class ConnectionController < AdminController
    def index
      connections = Connection.includes(:user)

      render_json_dump(
        connections: serialize_data(connections, ConnectionSerializer, root: false),
        sources: serialize_data(Source.all, SourceSerializer, root: false)
      )
    end

    def create
      connection = Connection.create(connection_params)

      if connection.errors.blank?
        render_serialized(connection, ConnectionSerializer, root: 'connection')
      else
        render json: failed_json.merge(errors: connection.errors.full_messages), status: 400
      end
    end

    def update
      connection = Connection.update(params[:id], connection_params)

      if connection.errors.blank?
        render_serialized(connection, ConnectionSerializer, root: 'connection')
      else
        render json: failed_json.merge(errors: connection.errors.full_messages), status: 400
      end
    end

    def sync
      connection = Connection.find_by(id: params[:id])
      raise Discourse::InvalidParameters.new(:id) unless connection

      Jobs.enqueue(
        :discourse_events_integration_sync_connection,
        connection_id: connection.id
      )

      render json: success_json
    end

    def destroy
      if Connection.destroy(params[:id])
        render json: success_json
      else
        render json: failed_json
      end
    end

    protected

    def connection_params
      result = params
        .require(:connection)
        .permit(
          :user_id,
          :category_id,
          :source_id,
          :client
        ).to_h

      if !result[:user_id] && params[:connection][:user].present?
        user = User.find_by(username: params.dig(:connection, :user, :username))
        result[:user_id] = user.id
      end

      result
    end
  end
end
