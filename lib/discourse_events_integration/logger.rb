# frozen_string_literal: true

module DiscourseEventsIntegration
  class Logger
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def info(message)
      log(:info, message)
    end

    def error(message)
      log(:error, message)
    end

    def log(level, message)
      Log.create(context: context, level: level, message: message)
    end
  end
end
