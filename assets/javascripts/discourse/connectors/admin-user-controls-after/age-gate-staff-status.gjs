import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

const USER_AGE_FIELD = "age_gate_confirmed_min_age";

export default class AgeGateStaffStatus extends Component {
  static shouldRender(_args, context) {
    return (
      context.siteSettings.age_confirm_gate_enabled &&
      !!context.currentUser?.staff
    );
  }

  @service siteSettings;

  @tracked saving = false;
  @tracked confirmedAge = this.#readAge();

  get minAge() {
    return this.siteSettings.age_confirm_gate_min_age;
  }

  get model() {
    return this.args.outletArgs?.model;
  }

  #readAge() {
    const model = this.args.outletArgs?.model;
    const value =
      model?.custom_fields?.[USER_AGE_FIELD] ?? model?.[USER_AGE_FIELD];
    if (value === null || value === undefined || value === "") {
      return "";
    }
    return String(value);
  }

  @action
  async setToSiteMin() {
    await this.#save(Number(this.minAge));
  }

  @action
  async clearConfirmation() {
    await this.#save(null);
  }

  @action
  async onInput(event) {
    this.confirmedAge = event.target.value;
  }

  @action
  async saveInput() {
    const raw = this.confirmedAge;
    if (raw === "" || raw === null || raw === undefined) {
      await this.#save(null);
      return;
    }
    await this.#save(Number(raw));
  }

  async #save(value) {
    const model = this.model;
    if (!model?.username) {
      return;
    }
    this.saving = true;
    try {
      await ajax(`/u/${model.username}.json`, {
        type: "PUT",
        data: {
          custom_fields: {
            [USER_AGE_FIELD]: value,
          },
        },
      });
      if (!model.custom_fields) {
        model.custom_fields = {};
      }
      model.custom_fields[USER_AGE_FIELD] = value;
      model[USER_AGE_FIELD] = value;
      this.confirmedAge =
        value === null || value === undefined ? "" : String(value);
    } catch (error) {
      popupAjaxError(error);
    } finally {
      this.saving = false;
    }
  }

  <template>
    <div class="age-confirm-gate-admin-user">
      <label>
        {{i18n "age_confirm_gate.admin_user.confirmed_min_age"}}
        <input
          type="number"
          min="0"
          value={{this.confirmedAge}}
          disabled={{this.saving}}
          {{on "input" this.onInput}}
          {{on "change" this.saveInput}}
        />
      </label>
      <button
        type="button"
        class="btn btn-default"
        disabled={{this.saving}}
        {{on "click" this.setToSiteMin}}
      >
        {{i18n
          "age_confirm_gate.admin_user.set_to_site_min"
          minAge=this.minAge
        }}
      </button>
      <button
        type="button"
        class="btn btn-danger"
        disabled={{this.saving}}
        {{on "click" this.clearConfirmation}}
      >
        {{i18n "age_confirm_gate.admin_user.clear"}}
      </button>
    </div>
  </template>
}
