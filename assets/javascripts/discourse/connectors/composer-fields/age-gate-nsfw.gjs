import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { i18n } from "discourse-i18n";

const NSFW_FIELD = "age_gate_nsfw";

export default class AgeGateNsfwComposer extends Component {
  static shouldRender(_args, context) {
    return context.siteSettings.age_confirm_gate_enabled;
  }

  @service siteSettings;
  @service currentUser;

  @tracked checked = !!this.args.outletArgs?.model?.age_gate_nsfw;

  get minAge() {
    return this.siteSettings.age_confirm_gate_min_age;
  }

  get isEditing() {
    return !!this.args.outletArgs?.model?.topic;
  }

  get canEdit() {
    if (!this.isEditing) {
      return true;
    }
    return !!this.currentUser?.staff;
  }

  get categoryAlreadyNsfw() {
    const category = this.args.outletArgs?.model?.category;
    return !!(
      category?.age_gate_nsfw || category?.custom_fields?.age_gate_nsfw
    );
  }

  @action
  onToggle(event) {
    const value = event.target.checked;
    this.checked = value;
    const model = this.args.outletArgs?.model;
    if (!model) {
      return;
    }
    model.set?.(NSFW_FIELD, value);
    model.age_gate_nsfw = value;
  }

  <template>
    {{#if this.canEdit}}
      <div class="age-confirm-gate-composer-nsfw">
        <label class="checkbox-label">
          <input
            type="checkbox"
            checked={{this.checked}}
            {{on "change" this.onToggle}}
          />
          {{i18n "age_confirm_gate.composer.nsfw_label" minAge=this.minAge}}
        </label>
        {{#if this.categoryAlreadyNsfw}}
          <p class="age-confirm-gate-composer-nsfw__note">
            {{i18n "age_confirm_gate.composer.category_already_nsfw"}}
          </p>
        {{/if}}
      </div>
    {{/if}}
  </template>
}
