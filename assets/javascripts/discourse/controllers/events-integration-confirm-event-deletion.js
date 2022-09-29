import Controller from "@ember/controller";
import ModalFunctionality from "discourse/mixins/modal-functionality";
import discourseComputed from "discourse-common/utils/decorators";
import Event from "../models/event";

export default Controller.extend(ModalFunctionality, {
  @discourseComputed("model.events")
  eventCount(events) {
    return events.length;
  },

  @discourseComputed("destroyTopics")
  btnLabel(destroyTopics) {
    return destroyTopics
      ? "admin.events_integration.event.delete.label_with_topics"
      : "admin.events_integration.event.delete.label";
  },

  actions: {
    toggleDestroyTopics() {
      this.toggleProperty("destroyTopics");
    },

    delete() {
      const events = this.model.events;
      const eventIds = events.map((e) => e.id);
      const opts = {
        event_ids: eventIds,
        destroy_topics: this.destroyTopics,
      };

      this.set("destroying", true);

      Event.destroy(opts)
        .then((result) => {
          if (result.success) {
            this.onDestroyEvents(
              events.filter((e) => result.destroyed_ids.includes(e.id))
            );
            this.onCloseModal();
            this.send("closeModal");
          } else {
            this.set("model.error", result.error);
          }
        })
        .finally(() => this.set("destroying", false));
    },

    cancel() {
      this.onCloseModal();
      this.send("closeModal");
    },
  },
});
