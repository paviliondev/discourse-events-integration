# frozen_string_literal: true

describe DiscourseEventsIntegration::AdminController do
  fab!(:moderator) { Fabricate(:user, moderator: true) }
  fab!(:admin) { Fabricate(:user, admin: true) }

  it "prevents access by non-admins" do
    sign_in(moderator)
    get "/admin/events-integration.json"
    expect(response.status).to eq(404)
  end

  it "allows access by admins" do
    sign_in(admin)
    get "/admin/events-integration.json"
    expect(response.status).to eq(204)
  end
end
