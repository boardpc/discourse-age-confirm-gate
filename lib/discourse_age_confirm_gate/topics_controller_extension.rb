# frozen_string_literal: true

module DiscourseAgeConfirmGate
  module TopicsControllerExtension
    def update
      guard_age_gate_nsfw_update!
      super
    end

    private

    def guard_age_gate_nsfw_update!
      return if guardian.is_staff?

      custom_fields =
        params[:custom_fields].presence || params.dig(:topic, :custom_fields).presence
      return if custom_fields.blank?
      return unless custom_fields.key?(NSFW_FIELD) || custom_fields.key?(NSFW_FIELD.to_sym)

      topic = Topic.find_by(id: params[:topic_id] || params[:id])
      return if topic.blank?

      key = custom_fields.key?(NSFW_FIELD) ? NSFW_FIELD : NSFW_FIELD.to_sym
      new_value = ActiveModel::Type::Boolean.new.cast(custom_fields[key])
      return if new_value == topic.age_gate_nsfw

      raise Discourse::InvalidAccess.new("age_gate_nsfw is locked after create for non-staff")
    end
  end
end
