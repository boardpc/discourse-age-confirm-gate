# frozen_string_literal: true

module DiscourseAgeConfirmGate
  module Access
    module_function

    def nsfw?(topic)
      return false if topic.blank?
      topic.age_gate_nsfw || topic.category&.age_gate_nsfw || false
    end

    def user_compliant?(user)
      return false if user.blank?

      confirmed = user.age_gate_confirmed_min_age
      return false if confirmed.nil?

      if SiteSetting.age_confirm_gate_require_reconfirm_on_threshold_raise
        confirmed >= SiteSetting.age_confirm_gate_min_age.to_i
      else
        true
      end
    end

    def allowed?(guardian_or_user, topic)
      return true unless SiteSetting.age_confirm_gate_enabled
      return true unless nsfw?(topic)

      guardian = normalize_guardian(guardian_or_user)
      return true if guardian.user&.staff?
      return false if guardian.anonymous?

      user_compliant?(guardian.user)
    end

    def blocked?(guardian_or_user, topic)
      return false unless SiteSetting.age_confirm_gate_enabled
      return false unless nsfw?(topic)
      !allowed?(guardian_or_user, topic)
    end

    def hide_topic?(guardian_or_user, topic)
      return false unless SiteSetting.age_confirm_gate_enabled
      return false unless nsfw?(topic)
      return false if allowed?(guardian_or_user, topic)

      guardian = normalize_guardian(guardian_or_user)

      if guardian.anonymous?
        return true if SiteSetting.age_confirm_gate_block_guests &&
          !SiteSetting.age_confirm_gate_guests_see_titles
        return SiteSetting.age_confirm_gate_topic_visibility == VISIBILITY_HIDE_ENTIRELY
      end

      SiteSetting.age_confirm_gate_topic_visibility == VISIBILITY_HIDE_ENTIRELY
    end

    def should_strip_posts?(guardian_or_user, topic)
      return false unless blocked?(guardian_or_user, topic)
      return false if hide_topic?(guardian_or_user, topic)

      # show_with_banner (or guests_see_titles): keep topic visible, strip content
      true
    end

    def blocked_message
      custom = SiteSetting.age_confirm_gate_blocked_message
      return custom if custom.present?

      I18n.t(
        "age_confirm_gate.default_blocked_message",
        min_age: SiteSetting.age_confirm_gate_min_age,
      )
    end

    def staff_verification_required?
      SiteSetting.age_confirm_gate_staff_verification_required
    end

    def normalize_guardian(guardian_or_user)
      return guardian_or_user if guardian_or_user.is_a?(Guardian)
      Guardian.new(guardian_or_user)
    end
  end
end
