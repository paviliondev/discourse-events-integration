import DiscourseRoute from "discourse/routes/discourse";
import Connection from "../models/connection";
import Source from "../models/source";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  model() {
    return Connection.all();
  },

  setupController(controller, model) {
    controller.setProperties({
      connections: A(model.connections.map((p) => Connection.create(p))),
      sources: A(model.sources.map((s) => Source.create(s))),
    });
  },
});
