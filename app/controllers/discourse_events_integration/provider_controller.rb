# frozen_string_literal: true

module DiscourseEventsIntegration
  class ProviderController < AdminController
    skip_before_action :preload_json, :check_xhr, only: [:authorize]
    skip_before_action :preload_json, :redirect_to_login_if_required, :check_xhr, :verify_authenticity_token, :ensure_admin, only: [:redirect]

    AUTH_SESSION_KEY = "events-integration-provider-auth"

    def index
      render_serialized(Provider.all, ProviderSerializer, root: 'providers')
    end

    def create
      provider = Provider.create(provider_params)

      if provider.errors.blank?
        render_serialized(provider, ProviderSerializer, root: 'provider')
      else
        render json: failed_json.merge(errors: provider.errors.full_messages), status: 400
      end
    end

    def update
      provider = Provider.update(params[:id], provider_params)

      if provider.errors.blank?
        render_serialized(provider, ProviderSerializer, root: 'provider')
      else
        render json: failed_json.merge(errors: provider.errors.full_messages), status: 400
      end
    end

    def destroy
      if Provider.destroy(params[:id])
        render json: success_json
      else
        render json: failed_json
      end
    end

    def authorize
      provider = Provider.find_by(id: params[:id])
      unless provider&.oauth2_type? && provider.can_authenticate?
        raise Discourse::InvalidParameters
      end

      state = "#{SecureRandom.hex}:#{provider.id}"
      secure_session["#{AUTH_SESSION_KEY}-#{current_user.id}"] = state

      redirect_to provider.authorization_url(state), allow_other_host: true
    end

    def redirect
      valid_state = params[:state] === secure_session["#{AUTH_SESSION_KEY}-#{current_user.id}"]

      unless valid_state && params[:code] && provider = Provider.find_by(id: params[:state].split(':').last.to_i)
        Log.create(log_type: 'error', message: "Invalid authorization response for provider #{params[:state]}")
        raise Discourse::InvalidParameters
      end

      provider.get_token(params[:code])

      redirect_to "/admin/events-integration/provider"
    end

    protected

    def provider_params
      params
        .require(:provider)
        .permit(
          :name,
          :provider_type,
          :username,
          :password,
          :token,
          :client_id,
          :client_secret
        )
    end
  end
end
