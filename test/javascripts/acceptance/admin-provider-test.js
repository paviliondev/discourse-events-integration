import selectKit from "discourse/tests/helpers/select-kit-helper";
import { acceptance, exists } from "discourse/tests/helpers/qunit-helpers";
import { test } from "qunit";
import { visit } from "@ember/test-helpers";

function providerRoutes(needs) {
  needs.pretender((server, helper) => {
    server.get("/admin/events-integration", () => {
      return helper.response({});
    });
    server.get("/admin/events-integration/provider", () => {
      return helper.response({
        providers: [
          {
            id: 1,
            name: 'my_provider',
          },
        ],
      });
    });
    server.put("/admin/events-integration/provider/new", () => {
      return helper.response({
        provider: {
          id: 2,
          name: 'my_new_provider',
          provider_type: 'developer',
          authenticated: true
        }
      });
    });
    server.put("/admin/events-integration/provider/:id", () => {
      return helper.response({
        provider: {
          id: 1,
          name: 'my_updated_provider',
          provider_type: 'developer',
          authenticated: true
        }
      });
    });
    server.delete("/admin/events-integration/provider/:id", () => {
      return helper.response({ "success": "OK" });
    });
  });
}

acceptance("Events Integration | Provider", function (needs) {
  needs.user();
  needs.settings({ events_integration_enabled: true });

  providerRoutes(needs);

  test("Displays the provider admin", async (assert) => {
    await visit("/admin/events-integration/provider");

    assert.ok(exists(".events-integration.provider"), "it shows the provider route");

    assert.equal(
      find(".admin-events-integration-controls h2").eq(0).text().trim(),
      "Providers",
      "title displayed"
    );
  });

  test("Add provider works", async (assert) => {
    await visit("/admin/events-integration/provider");

    await click("#add-provider");

    assert.ok(
      exists("tr[data-provider-id=new]"),
      "it displays a new provider row"
    );
    assert.ok(
      find("tr[data-provider-id=new] .save-provider").prop("disabled"),
      "it disables the save button"
    );

    await fillIn("tr[data-provider-id=new] .provider-name", "my_provider");

    assert.ok(
      find("tr[data-provider-id=new] .save-provider").prop("disabled") === false,
      "it enables the save button"
    );

    await click("tr[data-provider-id=new] .save-provider");
  });

  test("Edit provider works", async (assert) => {
    await visit("/admin/events-integration/provider");

    await fillIn("tr[data-provider-id=1] .provider-name", "my_updated_provider");

    assert.ok(
      find("tr[data-provider-id=1] .save-provider").prop("disabled") === false,
      "it enables the save button"
    );

    await click(".save-provider");
  });

  test("Appropriate credential controls show for different provider types", async (assert) => {
    await visit("/admin/events-integration/provider");

    assert.ok(
      find(".credentials-container").eq(0).text().trim(),
      "No Credentials",
      "no credentials displayed"
    );

    await selectKit(".provider-type").expand();
    await selectKit(".provider-type").selectRowByValue("icalendar");

    assert.ok(
      find("tr[data-provider-id=1] .credentials-container").eq(0).text().trim(),
      "No Credentials",
      "no credentials displayed"
    );

    await selectKit(".provider-type").expand();
    await selectKit(".provider-type").selectRowByValue("eventbrite");

    assert.ok(
      exists("input.token"),
      "it displays the token input"
    );
    assert.ok(
      exists(".btn.toggle-secret-visibility"),
      "it displays the secret visibility toggle"
    );

    await selectKit(".provider-type").expand();
    await selectKit(".provider-type").selectRowByValue("meetup");

    assert.ok(
      exists("input.client-id"),
      "it displays the client id input"
    );
    assert.ok(
      exists("input.client-secret"),
      "it displays the client secret input"
    );
    assert.ok(
      exists(".btn.toggle-secret-visibility"),
      "it displays the secret visibility toggle"
    );
  });
});
