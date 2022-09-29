import EmberObject from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

const Log = EmberObject.extend();

Log.reopenClass({
  list(data = {}) {
    return ajax("/admin/events-integration/log", {
      type: "GET",
      data,
    }).catch(popupAjaxError);
  },
});

export default Log;
