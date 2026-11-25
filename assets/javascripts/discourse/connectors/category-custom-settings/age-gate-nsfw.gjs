import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

const NSFW_FIELD = "age_gate_nsfw";

export default class AgeGateNsfwCategory extends Component {
  static shouldRender(_args, context) {
    return context.siteSettings.age_confirm_gate_enabled;
  }

  @service siteSettings;

  @tracked checked = this.#readChecked();

  get minAge() {
    return this.siteSettings.age_confirm_gate_min_age;
  }

  get category() {
    return this.args.outletArgs?.category;
  }

  #readChecked() {
    const category = this.args.outletArgs?.category;
    const value = category?.custom_fields?.[NSFW_FIELD] ?? category?.age_gate_nsfw;
    return value === true || value === "true";
  }

  @action
  onToggle(event) {
    const value = event.target.checked;
    this.checked = value;
    const category = this.category;
    if (!category) {
      return;
    }
    if (!category.custom_fields) {
      category.custom_fields = {};
    }
    category.custom_fields[NSFW_FIELD] = value;
    category.age_gate_nsfw = value;
  }

  <template>
    <section class="field age-confirm-gate-category-nsfw">
      <label class="checkbox-label">
        <input
          type="checkbox"
          checked={{this.checked}}
          {{on "change" this.onToggle}}
        />
        {{i18n "age_confirm_gate.category.nsfw_label" minAge=this.minAge}}
      </label>
    </section>
  </template>
}
