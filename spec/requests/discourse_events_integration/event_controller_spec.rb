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
      topic_id = topic.id
      post_id = post.id
      event_id = event.id

      delete "/admin/events-integration/event.json", params: {
        event_ids: [event_id],
        target: 'events_only'
      }

      expect(response.status).to eq(200)
      expect(response.parsed_body['destroyed_topics_event_ids'].blank?).to eq(true)
      expect(response.parsed_body['destroyed_event_ids']).to eq([event_id])

      expect(DiscourseEventsIntegration::Event.exists?(event_id)).to eq(false)
      expect(Topic.exists?(topic_id)).to eq(true)
      expect(Post.exists?(post_id)).to eq(true)
    end

    it "destroys topics and posts associated with events if requested" do
      topic_id = topic.id
      post_id = post.id
      event_id = event.id

      delete "/admin/events-integration/event.json", params: {
        event_ids: [event_id],
        target: 'events_and_topics'
      }

      expect(response.status).to eq(200)
      expect(response.parsed_body['destroyed_topics_event_ids']).to eq([event_id])
      expect(response.parsed_body['destroyed_event_ids']).to eq([event_id])

      expect(DiscourseEventsIntegration::Event.exists?(event_id)).to eq(false)
      expect(Topic.exists?(topic_id)).to eq(false)
      expect(Post.exists?(post_id)).to eq(false)
    end

    it "destroys topics associated with events if requested" do
      topic_id = topic.id
      post_id = post.id
      event_id = event.id

      delete "/admin/events-integration/event.json", params: {
        event_ids: [event_id],
        target: 'topics_only'
      }

      expect(response.status).to eq(200)
      expect(response.parsed_body['destroyed_topics_event_ids']).to eq([event_id])
      expect(response.parsed_body['destroyed_event_ids'].blank?).to be(true)

      expect(DiscourseEventsIntegration::Event.exists?(event_id)).to eq(true)
      expect(Topic.exists?(topic_id)).to eq(false)
      expect(Post.exists?(post_id)).to eq(false)
    end
  end
end
