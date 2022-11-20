import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "events-integration",
  initialize() {
    withPluginApi("1.4.0", (api) => {
      api.includePostAttributes("integration_event", "integration_event");

      api.addPostClassesCallback((attrs) => {
        if (attrs.post_number === 1 && attrs.integration_event) {
          return ["for-event"];
        }
      });

      api.decorateWidget("post-menu:before-extra-controls", (helper) => {
        const post = helper.getModel();

        if (post.integration_event && post.integration_event.can_manage) {
          return helper.attach("link", {
            attributes: {
              target: "_blank",
            },
            href: post.integration_event.admin_url,
            className: "manage-event",
            icon: "external-link-alt",
            label: "post.event.manage.label",
            title: "post.event.manage.title",
          });
        }
      });
    });
  },
};
