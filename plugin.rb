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
  require_relative "lib/discourse_age_confirm_gate/access"
  require_relative "lib/discourse_age_confirm_gate/guardian_extension"
  require_relative "lib/discourse_age_confirm_gate/topic_view_extension"
  require_relative "lib/discourse_age_confirm_gate/post_revisor_extension"
  require_relative "lib/discourse_age_confirm_gate/topics_controller_extension"
  require_relative "lib/discourse_age_confirm_gate/user_updater_extension"

  nsfw_field = DiscourseAgeConfirmGate::NSFW_FIELD
  user_age_field = DiscourseAgeConfirmGate::USER_AGE_FIELD

  register_topic_custom_field_type(nsfw_field, :boolean)
  register_editable_topic_custom_field(nsfw_field)
  register_category_custom_field_type(nsfw_field, :boolean)
  register_user_custom_field_type(user_age_field, :integer)
  register_editable_user_custom_field(user_age_field)
  register_editable_user_custom_field(user_age_field, staff_only: true)
  allow_staff_user_custom_field(user_age_field)
  allow_public_user_custom_field(user_age_field)

  DiscoursePluginRegistry.serialized_current_user_fields << user_age_field

  add_preloaded_topic_list_custom_field(nsfw_field)
  Site.preloaded_category_custom_fields << nsfw_field

  add_to_class(:topic, :age_gate_nsfw) do
    ActiveModel::Type::Boolean.new.cast(custom_fields[DiscourseAgeConfirmGate::NSFW_FIELD])
  end

  add_to_class(:topic, :age_gate_nsfw=) do |value|
    custom_fields[DiscourseAgeConfirmGate::NSFW_FIELD] = ActiveModel::Type::Boolean.new.cast(
      value,
    )
  end

  add_to_class(:category, :age_gate_nsfw) do
    ActiveModel::Type::Boolean.new.cast(custom_fields[DiscourseAgeConfirmGate::NSFW_FIELD])
  end

  add_to_class(:category, :age_gate_nsfw=) do |value|
    custom_fields[DiscourseAgeConfirmGate::NSFW_FIELD] = ActiveModel::Type::Boolean.new.cast(
      value,
    )
  end

  add_to_class(:user, :age_gate_confirmed_min_age) do
    value = custom_fields[DiscourseAgeConfirmGate::USER_AGE_FIELD]
    value.nil? ? nil : value.to_i
  end

  add_to_class(:user, :age_gate_confirmed_min_age=) do |value|
    if value.nil? || value == ""
      custom_fields.delete(DiscourseAgeConfirmGate::USER_AGE_FIELD)
    else
      custom_fields[DiscourseAgeConfirmGate::USER_AGE_FIELD] = value.to_i
    end
  end

  add_to_class(:user, :age_gate_compliant?) do
    DiscourseAgeConfirmGate::Access.user_compliant?(self)
  end

  reloadable_patch do
    Guardian.prepend(DiscourseAgeConfirmGate::GuardianExtension)
    TopicView.prepend(DiscourseAgeConfirmGate::TopicViewExtension)
    PostRevisor.prepend(DiscourseAgeConfirmGate::PostRevisorExtension)
    TopicsController.prepend(DiscourseAgeConfirmGate::TopicsControllerExtension)
    UserUpdater.prepend(DiscourseAgeConfirmGate::UserUpdaterExtension)
  end

  %i[topic_list_item listable_topic].each do |serializer|
    add_to_serializer(serializer, :age_gate_nsfw) { object.age_gate_nsfw }
    add_to_serializer(serializer, :age_gate_category_nsfw) do
      object.category&.age_gate_nsfw || false
    end
    add_to_serializer(serializer, :age_gate_effective_nsfw) do
      DiscourseAgeConfirmGate::Access.nsfw?(object)
    end
  end

  add_to_serializer(:topic_view, :age_gate_nsfw) { object.topic.age_gate_nsfw }
  add_to_serializer(:topic_view, :age_gate_category_nsfw) do
    object.topic.category&.age_gate_nsfw || false
  end
  add_to_serializer(:topic_view, :age_gate_effective_nsfw) do
    DiscourseAgeConfirmGate::Access.nsfw?(object.topic)
  end
  add_to_serializer(:topic_view, :age_gate_blocked) do
    DiscourseAgeConfirmGate::Access.blocked?(scope, object.topic)
  end
  add_to_serializer(:topic_view, :age_gate_blocked_message) do
    next nil unless DiscourseAgeConfirmGate::Access.blocked?(scope, object.topic)
    DiscourseAgeConfirmGate::Access.blocked_message
  end

  %i[basic_category category site_category].each do |serializer|
    add_to_serializer(serializer, :age_gate_nsfw) { object.age_gate_nsfw }
  end

  add_to_serializer(:current_user, :age_gate_confirmed_min_age) do
    object.age_gate_confirmed_min_age
  end
  add_to_serializer(:current_user, :age_gate_compliant) do
    DiscourseAgeConfirmGate::Access.user_compliant?(object)
  end
  add_to_serializer(:user, :age_gate_confirmed_min_age) { object.age_gate_confirmed_min_age }
  add_to_serializer(:user, :age_gate_compliant) do
    DiscourseAgeConfirmGate::Access.user_compliant?(object)
  end
end
