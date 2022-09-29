import DiscourseRoute from "discourse/routes/discourse";
import Event from "../models/event";
import Source from "../models/source";
import Topic from "discourse/models/topic";
import { A } from "@ember/array";

export default DiscourseRoute.extend({
  queryParams: {
    order: { refreshModel: true },
    asc: { refreshModel: true },
  },

  model(params) {
    let page = params.page || 0;
    let order = params.order || "start_time";
    let asc = params.asc || false;
    return Event.list({ page, order, asc });
  },

  setupController(controller, model) {
    controller.setProperties({
      page: model.page,
      events: A(
        model.events.map((event) => {
          let source = Source.create(event.source);
          let topics = event.topics.map((t) => Topic.create(t));
          return Object.assign(event, { source, topics });
        })
      ),
    });
  },
});
