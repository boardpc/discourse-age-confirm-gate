# frozen_string_literal: true

module DiscourseAgeConfirmGate
  module TopicViewExtension
    def initialize(topic_or_topic_id, user = nil, options = {})
      super
      strip_posts_for_age_gate! if should_strip_age_gate_posts?
    end

    private

    def should_strip_age_gate_posts?
      return false if @skip_post_loading
      Access.should_strip_posts?(@guardian, @topic)
    end

    def strip_posts_for_age_gate!
      @posts = []
      @filtered_posts = @topic.posts.none
      @contains_gaps = false
    end
  end
end
