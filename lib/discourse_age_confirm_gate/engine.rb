# frozen_string_literal: true

module DiscourseAgeConfirmGate
  NSFW_FIELD = "age_gate_nsfw"
  USER_AGE_FIELD = "age_gate_confirmed_min_age"

  VISIBILITY_SHOW_WITH_BANNER = "show_with_banner"
  VISIBILITY_HIDE_ENTIRELY = "hide_entirely"

  class Engine < ::Rails::Engine
    engine_name "discourse-age-confirm-gate"
    isolate_namespace DiscourseAgeConfirmGate
    config.autoload_paths << File.join(config.root, "lib")
  end
end
