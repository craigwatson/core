require 'singleton'

module Bucky
  class Tracking
    include Singleton

    def event(identity, action_name, occurred_at = Time.now)
      raise TypeError, "Identity cannot be nil" if identity.nil?

      if Rails.env.production?
        # tracking
        identity.delay(
          priority: Figaro.env.delayed_job_priority_low
        ).track(action_name, occurred_at)
      end
    end
  end
end
