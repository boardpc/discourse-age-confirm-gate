import Component from "@glimmer/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class AgeGateBadge extends Component {
  static shouldRender(args, context) {
    if (!context.siteSettings.age_confirm_gate_enabled) {
      return false;
    }
    const topic = args.outletArgs?.topic ?? args.topic;
    return !!(
      topic?.age_gate_effective_nsfw ||
      topic?.age_gate_nsfw ||
      topic?.age_gate_category_nsfw
    );
  }

  @service siteSettings;

  get minAge() {
    return this.siteSettings.age_confirm_gate_min_age;
  }

  <template>
    <span
      class="age-confirm-gate-badge"
      title={{i18n "age_confirm_gate.badge.nsfw" minAge=this.minAge}}
    >
      {{i18n "age_confirm_gate.badge.nsfw" minAge=this.minAge}}
    </span>
  </template>
}
