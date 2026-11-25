# frozen_string_literal: true

module DiscourseAgeConfirmGate
  module PostRevisorExtension
    def revise!(editor, fields, opts = {})
      guard_age_gate_nsfw_field!(editor, fields)
      super
    end

    private

    def guard_age_gate_nsfw_field!(editor, fields)
      return unless fields.is_a?(Hash)

      custom_fields = fields[:custom_fields] || fields["custom_fields"]
      return if custom_fields.blank?
      return unless custom_fields.key?(NSFW_FIELD) || custom_fields.key?(NSFW_FIELD.to_sym)

      key = custom_fields.key?(NSFW_FIELD) ? NSFW_FIELD : NSFW_FIELD.to_sym
      new_value = ActiveModel::Type::Boolean.new.cast(custom_fields[key])
      old_value = @topic.age_gate_nsfw

      return if new_value == old_value
      return if editor&.staff?

      raise Discourse::InvalidAccess.new("age_gate_nsfw is locked after create for non-staff")
    end
  end
end
