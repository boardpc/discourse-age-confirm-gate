import Component from "@glimmer/component";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";
import { htmlSafe } from "@ember/template";

export default class AgeGateBanner extends Component {
  static shouldRender(args, context) {
    return (
      context.siteSettings.age_confirm_gate_enabled &&
      !!args.model?.age_gate_blocked
    );
  }

  @service siteSettings;
  @service currentUser;

  get minAge() {
    return this.siteSettings.age_confirm_gate_min_age;
  }

  get message() {
    const custom =
      this.args.outletArgs?.model?.age_gate_blocked_message ||
      this.siteSettings.age_confirm_gate_blocked_message;
    if (custom) {
      return custom;
    }
    return i18n("age_confirm_gate.banner.default_message", {
      minAge: this.minAge,
    });
  }

  get showLoginPrompt() {
    return !this.currentUser;
  }

  <template>
    <div class="age-confirm-gate-banner" role="alert">
      <h2 class="age-confirm-gate-banner__title">
        {{i18n "age_confirm_gate.banner.title"}}
      </h2>
      <p class="age-confirm-gate-banner__message">{{htmlSafe this.message}}</p>
      {{#if this.showLoginPrompt}}
        <p class="age-confirm-gate-banner__login">
          {{i18n "age_confirm_gate.banner.login_prompt"}}
        </p>
      {{/if}}
    </div>
  </template>
}
