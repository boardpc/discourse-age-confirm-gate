# frozen_string_literal: true

RSpec.describe DiscourseAgeConfirmGate::Access do
  fab!(:category)
  fab!(:topic) { Fabricate(:topic, category: category) }
  fab!(:user)
  fab!(:admin)
  fab!(:moderator)

  before do
    SiteSetting.age_confirm_gate_enabled = true
    SiteSetting.age_confirm_gate_min_age = 18
    SiteSetting.age_confirm_gate_topic_visibility = "show_with_banner"
    SiteSetting.age_confirm_gate_require_reconfirm_on_threshold_raise = true
    SiteSetting.age_confirm_gate_staff_verification_required = false
    SiteSetting.age_confirm_gate_block_guests = true
    SiteSetting.age_confirm_gate_guests_see_titles = false
  end

  def mark_topic_nsfw!(value = true)
    topic.custom_fields[DiscourseAgeConfirmGate::NSFW_FIELD] = value
    topic.save_custom_fields
    topic.reload
  end

  def mark_category_nsfw!(value = true)
    category.custom_fields[DiscourseAgeConfirmGate::NSFW_FIELD] = value
    category.save_custom_fields
    category.reload
    topic.reload
  end

  def confirm_user!(target = user, age: 18)
    target.custom_fields[DiscourseAgeConfirmGate::USER_AGE_FIELD] = age
    target.save_custom_fields
    target.reload
  end

  describe ".nsfw?" do
    it "is false when neither topic nor category is NSFW" do
      expect(described_class.nsfw?(topic)).to eq(false)
    end

    it "is true when topic is NSFW" do
      mark_topic_nsfw!
      expect(described_class.nsfw?(topic)).to eq(true)
    end

    it "is true when category is NSFW and topic is not" do
      mark_category_nsfw!
      expect(topic.age_gate_nsfw).to eq(false)
      expect(described_class.nsfw?(topic)).to eq(true)
    end

    it "is true when both are NSFW" do
      mark_topic_nsfw!
      mark_category_nsfw!
      expect(described_class.nsfw?(topic)).to eq(true)
    end
  end

  describe ".user_compliant?" do
    it "is false for nil confirmation" do
      expect(described_class.user_compliant?(user)).to eq(false)
    end

    it "requires confirmed age >= site min when reconfirm is enabled" do
      confirm_user!(age: 16)
      expect(described_class.user_compliant?(user)).to eq(false)

      confirm_user!(age: 18)
      expect(described_class.user_compliant?(user)).to eq(true)
    end

    it "accepts any non-nil confirmation when reconfirm is disabled" do
      SiteSetting.age_confirm_gate_require_reconfirm_on_threshold_raise = false
      confirm_user!(age: 16)
      SiteSetting.age_confirm_gate_min_age = 21
      expect(described_class.user_compliant?(user)).to eq(true)
    end

    it "requires reconfirm after threshold raise when enabled" do
      confirm_user!(age: 18)
      SiteSetting.age_confirm_gate_min_age = 21
      expect(described_class.user_compliant?(user)).to eq(false)
    end
  end

  describe ".allowed?" do
    before { mark_topic_nsfw! }

    it "allows staff without confirmation" do
      expect(described_class.allowed?(Guardian.new(admin), topic)).to eq(true)
      expect(described_class.allowed?(Guardian.new(moderator), topic)).to eq(true)
    end

    it "denies anonymous users" do
      expect(described_class.allowed?(Guardian.new(nil), topic)).to eq(false)
    end

    it "denies non-compliant users" do
      expect(described_class.allowed?(Guardian.new(user), topic)).to eq(false)
    end

    it "allows compliant users" do
      confirm_user!
      expect(described_class.allowed?(Guardian.new(user), topic)).to eq(true)
    end

    it "allows everyone when topic is not effectively NSFW" do
      mark_topic_nsfw!(false)
      expect(described_class.allowed?(Guardian.new(nil), topic)).to eq(true)
    end
  end

  describe ".hide_topic?" do
    before { mark_topic_nsfw! }

    it "hides from guests when block_guests and not guests_see_titles" do
      expect(described_class.hide_topic?(Guardian.new(nil), topic)).to eq(true)
    end

    it "does not hide from guests when guests_see_titles is enabled" do
      SiteSetting.age_confirm_gate_guests_see_titles = true
      expect(described_class.hide_topic?(Guardian.new(nil), topic)).to eq(false)
      expect(described_class.should_strip_posts?(Guardian.new(nil), topic)).to eq(true)
    end

    it "hides for non-compliant users when visibility is hide_entirely" do
      SiteSetting.age_confirm_gate_topic_visibility = "hide_entirely"
      expect(described_class.hide_topic?(Guardian.new(user), topic)).to eq(true)
    end

    it "does not hide for non-compliant users when show_with_banner" do
      expect(described_class.hide_topic?(Guardian.new(user), topic)).to eq(false)
      expect(described_class.should_strip_posts?(Guardian.new(user), topic)).to eq(true)
    end

    it "never hides for staff" do
      SiteSetting.age_confirm_gate_topic_visibility = "hide_entirely"
      expect(described_class.hide_topic?(Guardian.new(admin), topic)).to eq(false)
    end
  end

  describe "Guardian can_see_topic?" do
    before { mark_category_nsfw! }

    it "returns false for guests when hide applies" do
      expect(Guardian.new(nil).can_see_topic?(topic)).to eq(false)
    end

    it "returns true for guests when guests_see_titles" do
      SiteSetting.age_confirm_gate_guests_see_titles = true
      expect(Guardian.new(nil).can_see_topic?(topic)).to eq(true)
    end

    it "returns false for non-compliant users in hide_entirely mode" do
      SiteSetting.age_confirm_gate_topic_visibility = "hide_entirely"
      expect(Guardian.new(user).can_see_topic?(topic)).to eq(false)
    end

    it "returns true for non-compliant users in show_with_banner mode" do
      expect(Guardian.new(user).can_see_topic?(topic)).to eq(true)
    end

    it "returns true for staff in hide_entirely mode" do
      SiteSetting.age_confirm_gate_topic_visibility = "hide_entirely"
      expect(Guardian.new(admin).can_see_topic?(topic)).to eq(true)
    end
  end

  describe "staff verification lock" do
    it "strips self-updates when staff verification is required" do
      SiteSetting.age_confirm_gate_staff_verification_required = true
      updater = UserUpdater.new(user, user)
      updater.update(custom_fields: { DiscourseAgeConfirmGate::USER_AGE_FIELD => 18 })
      user.reload
      expect(user.age_gate_confirmed_min_age).to eq(nil)
    end

    it "allows staff to set the field when staff verification is required" do
      SiteSetting.age_confirm_gate_staff_verification_required = true
      updater = UserUpdater.new(admin, user)
      updater.update(custom_fields: { DiscourseAgeConfirmGate::USER_AGE_FIELD => 18 })
      user.reload
      expect(user.age_gate_confirmed_min_age).to eq(18)
    end
  end

  describe "category OR topic matrix" do
    [
      [false, false, false],
      [true, false, true],
      [false, true, true],
      [true, true, true],
    ].each do |category_nsfw, topic_nsfw, expected|
      it "gates=#{expected} for category=#{category_nsfw} topic=#{topic_nsfw}" do
        mark_category_nsfw!(category_nsfw)
        mark_topic_nsfw!(topic_nsfw)
        expect(described_class.nsfw?(topic)).to eq(expected)
        expect(described_class.blocked?(Guardian.new(user), topic)).to eq(expected)
      end
    end
  end
end
