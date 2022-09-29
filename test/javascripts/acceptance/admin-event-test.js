import selectKit from "discourse/tests/helpers/select-kit-helper";
import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

function sourceRoutes(needs) {
  needs.pretender((server, helper) => {
    server.get("/admin/events-integration", () => {
      return helper.response({});
    });
    server.get("/admin/events-integration/event", () => {
      return helper.response({
        events: [
          {
            id: 1,
            start_time: "2022-11-06T18:00:00.000Z",
            end_time: "2022-11-06T21:00:00.000Z",
            name: "La Traviata",
            description: "An opera in three acts by Giuseppe Verdi set to an Italian libretto by Francesco Maria Piave.",
            status: "draft",
            url: "https://event-platfom.com/events/la-traviata",
            created_at: "2022-09-28T14:38:03.711Z",
            updated_at: "2022-09-28T14:38:03.711Z",
            topics: [
              {
                id: 1,
                title: "Event Topic",
                fancy_title: "Event Topic"
              }
            ],
            source: {
              id: 1,
              name: "my_source",
              provider_id: 1
            }
          },
        ],
        page: 1
      });
    });
    server.delete("/admin/events-integration/event", () => {
      return helper.response({ "success": "OK" });
    });
  });
}

acceptance("Events Integration | Event", function (needs) {
  needs.user();
  needs.settings({ events_integration_enabled: true });

  sourceRoutes(needs);

  test("Displays the event admin", async (assert) => {
    await visit("/admin/events-integration/event");

    assert.ok(exists(".events-integration.event"), "it shows the event route");

    assert.equal(
      find(".admin-events-integration-controls h2").eq(0).text().trim(),
      "Events",
      "title displayed"
    );

    assert.equal(
      find(".events-integration-event-row .start-time").eq(0).text().trim(),
      "Nov 6, 2022 7:00 pm",
      "Start time displayed"
    );
  });
});
