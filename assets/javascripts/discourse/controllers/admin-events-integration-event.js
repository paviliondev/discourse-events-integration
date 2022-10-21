import Controller from "@ember/controller";
import { notEmpty } from "@ember/object/computed";
import showModal from "discourse/lib/show-modal";
import discourseComputed from "discourse-common/utils/decorators";
import Message from "../mixins/message";
import { A } from "@ember/array";

export default Controller.extend(Message, {
  hasEvents: notEmpty("events"),
  selectedEvents: A(),
  selectAll: false,
  order: null,
  asc: null,
  view: "event",

  @discourseComputed("selectedEvents.[]", "hasEvents")
  deleteDisabled(selectedEvents, hasEvents) {
    return !hasEvents || !selectedEvents.length;
  },

  @discourseComputed("hasEvents")
  selectDisabled(hasEvents) {
    return !hasEvents;
  },

  actions: {
    showSelect() {
      this.toggleProperty("showSelect");

      if (!this.showSelect) {
        this.setProperties({
          selectedEvents: A(),
          selectAll: false,
        });
      }
    },

    modifySelection(events, checked) {
      if (checked) {
        this.get("selectedEvents").pushObjects(events);
      } else {
        this.get("selectedEvents").removeObjects(events);
      }
    },

    openDelete() {
      const modal = showModal("events-integration-confirm-event-deletion", {
        model: {
          events: this.selectedEvents,
        },
      });

      modal.setProperties({
        onDestroyEvents: (destroyedEvents) => {
          this.get("events").removeObjects(destroyedEvents);
        },
        onCloseModal: () => {
          this.set("showSelect", false);
        },
      });
    },
  },
});
