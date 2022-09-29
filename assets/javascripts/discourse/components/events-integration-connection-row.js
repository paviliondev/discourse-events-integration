import Component from "@ember/component";
import Connection from "../models/connection";
import discourseComputed from "discourse-common/utils/decorators";
import { contentsMap } from "../lib/events-integration";

const CLIENTS = ["events", "discourse_events"];

export default Component.extend({
  tagName: "tr",
  attributeBindings: ["connection.id:data-connection-id"],
  classNames: ["events-integration-connection-row"],

  didReceiveAttrs() {
    this.set(
      "currentConnection",
      Connection.create(JSON.parse(JSON.stringify(this.connection)))
    );
  },

  willDestroyElement() {
    this._super(...arguments);
    this.setMessage("info", "info");
  },

  @discourseComputed
  clients() {
    return contentsMap(CLIENTS);
  },

  @discourseComputed(
    "connection.user.username",
    "connection.category_id",
    "connection.source_id",
    "connection.client",
    "connection.from_time",
    "connection.to_time"
  )
  connectionChanged(username, categoryId, sourceId, client, fromTime, toTime) {
    const cc = this.currentConnection;
    return (
      cc.get("user.username") !== username ||
      cc.category_id !== categoryId ||
      cc.source_id !== sourceId ||
      cc.client !== client ||
      cc.from_time !== fromTime ||
      cc.to_time !== toTime
    );
  },

  @discourseComputed(
    "connectionChanged",
    "connection.user.username",
    "connection.category_id",
    "connection.source_id",
    "connection.client"
  )
  saveDisabled(connectionChanged, username, categoryId, sourceId, client) {
    return (
      !connectionChanged || !username || !categoryId || !sourceId || !client
    );
  },

  @discourseComputed("connectionChanged")
  saveClass(connectionChanged) {
    return connectionChanged
      ? "btn-primary save-connection"
      : "save-connection";
  },

  @discourseComputed("syncDisabled")
  syncClass(syncDisabled) {
    return syncDisabled ? "sync-connection" : "btn-primary sync-connection";
  },

  @discourseComputed("connectionChanged", "loading")
  syncDisabled(connectionChanged, loading) {
    return connectionChanged || loading;
  },

  actions: {
    updateUser(usernames) {
      const connection = this.connection;
      if (!connection.user) {
        connection.set("user", {});
      }
      connection.set("user.username", usernames[0]);
    },

    saveConnection() {
      const connection = JSON.parse(JSON.stringify(this.connection));

      if (!connection.source_id) {
        return;
      }

      this.set("loading", true);

      Connection.update(connection)
        .then((result) => {
          if (result) {
            this.setProperties({
              currentConnection: result.connection,
              connection: Connection.create(result.connection),
            });
          } else if (this.currentSource.id !== "new") {
            this.set(
              "connection",
              JSON.parse(JSON.stringify(this.currentConnection))
            );
          }
        })
        .finally(() => {
          this.set("loading", false);
        });
    },

    syncConnection() {
      const connection = this.connection;

      this.set("loading", true);
      Connection.sync(connection)
        .then((result) => {
          if (result.success) {
            this.setMessage("sync_started", "success");
          } else {
            this.setMessage("sync_failed_to_start", "error");
          }
        })
        .finally(() => {
          this.set("loading", false);

          setTimeout(() => {
            if (!this.isDestroying && !this.isDestroyed) {
              this.setMessage("info", "info");
            }
          }, 5000);
        });
    },
  },
});
