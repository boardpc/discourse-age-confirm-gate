# frozen_string_literal: true

module DiscourseAgeConfirmGate
  module UserUpdaterExtension
    def update(attributes = {})
      guard_age_gate_user_field!(attributes)
      super
    end

    private

    def guard_age_gate_user_field!(attributes)
      return unless Access.staff_verification_required?
      return if @guardian&.is_staff?

      custom_fields = attributes[:custom_fields] || attributes["custom_fields"]
      return if custom_fields.blank?

      custom_fields.delete(USER_AGE_FIELD)
      custom_fields.delete(USER_AGE_FIELD.to_sym)
    end
  end
end
