import { withPluginApi } from "discourse/lib/plugin-api";

const NSFW_FIELD = "age_gate_nsfw";
const USER_AGE_FIELD = "age_gate_confirmed_min_age";

function initializeAgeConfirmGate(api) {
  const siteSettings = api.container.lookup("service:site-settings");

  if (!siteSettings.age_confirm_gate_enabled) {
    return;
  }

  api.serializeOnCreate(NSFW_FIELD);
  api.serializeToTopic(NSFW_FIELD, `topic.${NSFW_FIELD}`);

  api.modifyClass(
    "model:composer",
    (Superclass) =>
      class extends Superclass {
        age_gate_nsfw = false;
      }
  );

  // Ensure preferences saves include our custom field.
  api.modifyClass(
    "controller:preferences/profile",
    (Superclass) =>
      class extends Superclass {
        save() {
          if (!this.saveAttrNames.includes("custom_fields")) {
            this.saveAttrNames.push("custom_fields");
          }

          const model = this.model;
          if (
            model &&
            !siteSettings.age_confirm_gate_staff_verification_required
          ) {
            model.custom_fields ??= {};
            if (
              model.custom_fields[USER_AGE_FIELD] === undefined &&
              model[USER_AGE_FIELD] !== undefined
            ) {
              model.custom_fields[USER_AGE_FIELD] = model[USER_AGE_FIELD];
            }
          }

          return super.save(...arguments);
        }
      }
  );

  // Pass plugin custom fields through signup when self-confirm is allowed.
  if (!siteSettings.age_confirm_gate_staff_verification_required) {
    api.modifyClass(
      "controller:create-account",
      (Superclass) =>
        class extends Superclass {
          performAccountCreation() {
            const account = this.account || this.model;
            const ageValue = account?.custom_fields?.[USER_AGE_FIELD];
            if (ageValue !== undefined && ageValue !== null) {
              this.set("accountCustomFields", {
                ...(this.accountCustomFields || {}),
                [USER_AGE_FIELD]: ageValue,
              });
            }
            return super.performAccountCreation(...arguments);
          }
        }
    );
  }
}

export default {
  name: "age-confirm-gate",
  initialize() {
    withPluginApi(initializeAgeConfirmGate);
  },
};
