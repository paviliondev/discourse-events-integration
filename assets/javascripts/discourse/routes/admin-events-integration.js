import DiscourseRoute from "discourse/routes/discourse";

export default DiscourseRoute.extend({
  afterModel(model, transition) {
    if (transition.to.name === "admin.eventsIntegration.index") {
      this.transitionTo("admin.eventsIntegration.provider");
    }
  },

  actions: {
    showSettings() {
      const controller = this.controllerFor("adminSiteSettings");
      this.transitionTo("adminSiteSettingsCategory", "plugins").then(() => {
        controller.set("filter", "plugin:discourse-events-integration");
        controller.set("_skipBounce", true);
        controller.filterContentNow("plugins");
      });
    },
  },
});
