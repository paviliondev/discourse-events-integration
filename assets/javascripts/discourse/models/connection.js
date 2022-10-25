import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { A } from "@ember/array";

const Connection = EmberObject.extend({
  filters: A(),
});

Connection.reopenClass({
  all() {
    return ajax("/admin/events-integration/connection").catch(popupAjaxError);
  },

  update(connection) {
    return ajax(`/admin/events-integration/connection/${connection.id}`, {
      type: "PUT",
      contentType: "application/json",
      data: JSON.stringify({ connection }),
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
