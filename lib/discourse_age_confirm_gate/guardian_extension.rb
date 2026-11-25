# frozen_string_literal: true

module DiscourseAgeConfirmGate
  module GuardianExtension
    def can_see_topic?(topic, hide_deleted = true)
      return false unless super
      return true unless SiteSetting.age_confirm_gate_enabled
      return true unless Access.nsfw?(topic)
      return true unless Access.hide_topic?(self, topic)

      false
    end
  end
end
