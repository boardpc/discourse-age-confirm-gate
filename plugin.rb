# frozen_string_literal: true

# name: discourse-age-confirm-gate
# about: Age-gate NSFW topics and categories; require user age confirmation without storing DOB
# version: 0.1.0
# authors: BoardPC
# url: https://github.com/boardpc/discourse-age-confirm-gate
# required_version: 3.3.0

enabled_site_setting :age_confirm_gate_enabled

register_asset "stylesheets/common/age-confirm-gate.scss"

require_relative "lib/discourse_age_confirm_gate/engine"

after_initialize do
  # Feature modules are loaded in subsequent commits.
end
