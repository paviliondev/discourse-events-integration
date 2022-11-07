# frozen_string_literal: true
module EventsIntegrationGuardianExtension
  def can_edit_post?(post)
    return false if post.event_connection.present?
    super
  end
end
