import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

const USER_AGE_FIELD = "age_gate_confirmed_min_age";

export default class AgeGateConfirmPreferences extends Component {
  static shouldRender(_args, context) {
    return context.siteSettings.age_confirm_gate_enabled;
  }

  @service siteSettings;

  @tracked checked = this.#isConfirmed();

  get minAge() {
    return this.siteSettings.age_confirm_gate_min_age;
  }

  get staffVerificationRequired() {
    return this.siteSettings.age_confirm_gate_staff_verification_required;
  }

  get model() {
    return this.args.outletArgs?.model;
  }

  get confirmedAge() {
    return (
      this.model?.custom_fields?.[USER_AGE_FIELD] ??
      this.model?.[USER_AGE_FIELD]
    );
  }

  get statusText() {
    const age = this.confirmedAge;
    if (age === null || age === undefined || age === "") {
      return i18n("age_confirm_gate.preferences.status_not_confirmed");
    }
    return i18n("age_confirm_gate.preferences.status_confirmed", { age });
  }

  #isConfirmed() {
    const age = this.confirmedAge;
    if (age === null || age === undefined || age === "") {
      return false;
    }
    return Number(age) >= Number(this.minAge);
  }

  @action
  onToggle(event) {
    const value = event.target.checked;
    this.checked = value;
    const model = this.model;
    if (!model) {
      return;
    }
    if (!model.custom_fields) {
      model.custom_fields = {};
    }
    const next = value ? Number(this.minAge) : null;
    model.custom_fields[USER_AGE_FIELD] = next;
    model[USER_AGE_FIELD] = next;
  }

  <template>
    <div class="control-group age-confirm-gate-preferences">
      <label class="control-label">
        {{i18n "age_confirm_gate.preferences.confirm_label" minAge=this.minAge}}
      </label>

      {{#if this.staffVerificationRequired}}
        <div class="controls">
          <p
            class="age-confirm-gate-preferences__status"
          >{{this.statusText}}</p>
          <p class="age-confirm-gate-preferences__note">
            {{i18n "age_confirm_gate.preferences.staff_verification_note"}}
          </p>
        </div>
      {{else}}
        <div class="controls">
          <label class="checkbox-label">
            <input
              type="checkbox"
              checked={{this.checked}}
              {{on "change" this.onToggle}}
            />
            {{i18n
              "age_confirm_gate.preferences.confirm_label"
              minAge=this.minAge
            }}
          </label>
        </div>
      {{/if}}
    </div>
  </template>
}
