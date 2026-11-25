import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

const USER_AGE_FIELD = "age_gate_confirmed_min_age";

export default class AgeGateConfirmSignup extends Component {
  static shouldRender(_args, context) {
    return (
      context.siteSettings.age_confirm_gate_enabled &&
      !context.siteSettings.age_confirm_gate_staff_verification_required
    );
  }

  @service siteSettings;

  @tracked checked = false;

  get minAge() {
    return this.siteSettings.age_confirm_gate_min_age;
  }

  get account() {
    return this.args.outletArgs?.account;
  }

  @action
  onToggle(event) {
    const value = event.target.checked;
    this.checked = value;
    const account = this.account;
    if (!account) {
      return;
    }
    if (!account.userFields) {
      account.userFields = {};
    }
    if (!account.custom_fields) {
      account.custom_fields = {};
    }
    const next = value ? Number(this.minAge) : null;
    account.custom_fields[USER_AGE_FIELD] = next;
  }

  <template>
    <div class="age-confirm-gate-signup">
      <label class="checkbox-label">
        <input
          type="checkbox"
          checked={{this.checked}}
          {{on "change" this.onToggle}}
        />
        {{i18n "age_confirm_gate.signup.confirm_label" minAge=this.minAge}}
      </label>
    </div>
  </template>
}
