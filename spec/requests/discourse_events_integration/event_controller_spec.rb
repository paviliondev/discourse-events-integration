# frozen_string_literal: true

describe DiscourseEventsIntegration::EventController do
  fab!(:connection) { Fabricate(:discourse_events_integration_connection) }
  fab!(:event) { Fabricate(:discourse_events_integration_event) }
  fab!(:user) { Fabricate(:user, admin: true) }

  before do
    sign_in(user)
  end

  it "lists events" do
    get "/admin/events-integration/event.json"

    expect(response.status).to eq(200)
    expect(response.parsed_body['events'].first['id']).to eq(event.id)
  end

  context("when destroying") do
    fab!(:topic) { Fabricate(:topic) }
    fab!(:post) { Fabricate(:post, topic: topic, user: user, raw: event.description) }
    fab!(:event_connection) { Fabricate(:discourse_events_integration_event_connection, event: event, topic: topic, post: post) }

    it "destroys events" do
      delete "/admin/events-integration/event.json", params: {
        event_ids: [event.id]
      }

      expect(response.status).to eq(200)
      expect(DiscourseEventsIntegration::Event.exists?(event.id)).to eq(false)
      expect(Topic.exists?(topic.id)).to eq(true)
      expect(Post.exists?(post.id)).to eq(true)
    end

    it "destroys topics and posts associated with events if requested" do
      topic_id = topic.id
      post_id = post.id

      delete "/admin/events-integration/event.json", params: {
        event_ids: [event.id],
        destroy_topics: true
      }

      expect(response.status).to eq(200)
      expect(Topic.exists?(topic_id)).to eq(false)
      expect(Post.exists?(post_id)).to eq(false)
    end
  end
end
