# frozen_string_literal: true

module DiscourseEventsIntegration
  class AdminController < ::Admin::AdminController
    before_action :ensure_admin

    def index
    end
  end
end
