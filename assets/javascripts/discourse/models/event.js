import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const Event = EmberObject.extend();

Event.reopenClass({
  list(data = {}) {
    return ajax("/admin/events-integration/event", {
      type: "GET",
      data,
    }).catch(popupAjaxError);
  },

  destroy(data) {
    return ajax("/admin/events-integration/event", {
      type: "DELETE",
      data,
    }).catch(popupAjaxError);
  },
});

export default Event;
