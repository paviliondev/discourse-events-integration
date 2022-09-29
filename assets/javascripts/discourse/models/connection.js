import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const Connection = EmberObject.extend();

Connection.reopenClass({
  all() {
    return ajax("/admin/events-integration/connection").catch(popupAjaxError);
  },

  update(connection) {
    return ajax(`/admin/events-integration/connection/${connection.id}`, {
      type: "PUT",
      data: {
        connection,
      },
    }).catch(popupAjaxError);
  },

  sync(connection) {
    return ajax(`/admin/events-integration/connection/${connection.id}`, {
      type: "POST",
    }).catch(popupAjaxError);
  },

  destroy(connection) {
    return ajax(`/admin/events-integration/connection/${connection.id}`, {
      type: "DELETE",
    }).catch(popupAjaxError);
  },
});

export default Connection;
