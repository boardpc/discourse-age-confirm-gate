import Component from "@glimmer/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

export default class AgeGateCategoryBadge extends Component {
  static shouldRender(args, context) {
    if (!context.siteSettings.age_confirm_gate_enabled) {
      return false;
    }
    const category = args.outletArgs?.category ?? args.category;
    return !!(
      category?.age_gate_nsfw || category?.custom_fields?.age_gate_nsfw
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
