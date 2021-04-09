require_relative "../../lib/special_route_publisher"
require "securerandom"

RSpec.describe SpecialRoutePublisher, "#publish_special_routes" do
  let(:publishing_api_endpoint) { Plek.find("publishing-api") }

  let(:logger) { double("logger") }
  before do
    allow(Logger).to receive(:new).and_return(logger)
    allow(logger).to receive(:info)
  end

  context "Special routes" do
    let(:api_content_route) do
      {
        content_id: "16ca5ac1-7df5-4137-9f83-0270fcfc8bb5",
        base_path: "/api/content",
        title: "Content API",
        description: "API exposing all content on GOV.UK.",
        type: "prefix",
        rendering_app: "content-store",
      }
    end

    let(:typeless_route) do
      {
        content_id: SecureRandom.uuid,
        base_path: "/typeless-path",
        title: "Typeless",
        rendering_app: "content-store",
      }
    end

    let(:invalid_route) do
      {
        content_id: SecureRandom.uuid,
        base_path: "/something-that-doesnt-matter",
      }
    end

    before do
      allow(SpecialRoutePublisher).to receive(:load_special_routes).and_return(routes)
    end

    context "with a valid route" do
      let(:routes) { [api_content_route] }

      it "calls the Publishing API to reserve a path, put content and publish it" do
        stub_put_path = stub_request(:put, "#{publishing_api_endpoint}/paths#{api_content_route.fetch(:base_path)}")
          .with(body: "{\"publishing_app\":\"special-route-publisher\",\"override_existing\":true}")

        stub_put_content = stub_request(:put, "#{publishing_api_endpoint}/v2/content/#{api_content_route.fetch(:content_id)}")

        stub_publish_content = stub_request(:post, "#{publishing_api_endpoint}/v2/content/#{api_content_route.fetch(:content_id)}/publish")
          .with(body: "{\"update_type\":null}")

        expect(logger).to receive(:info).with(/Publishing/)

        described_class.publish_special_routes

        expect(stub_put_path).to have_been_requested
        expect(stub_put_content).to have_been_requested
        expect(stub_publish_content).to have_been_requested
      end

      context "without a specific type" do
        let(:routes) { [typeless_route] }

        it "calls the Publishing API with an exact type" do
          stub_request(:put, "#{publishing_api_endpoint}/paths#{typeless_route.fetch(:base_path)}")

          stub_put_content = stub_request(:put, "#{publishing_api_endpoint}/v2/content/#{typeless_route.fetch(:content_id)}")
            .with(body: hash_including("routes" => [{ "path" => "/typeless-path", "type" => "exact" }]))

          stub_request(:post, "#{publishing_api_endpoint}/v2/content/#{typeless_route.fetch(:content_id)}/publish")

          described_class.publish_special_routes

          expect(stub_put_content).to have_been_requested
        end
      end
    end

    context "with an invalid route" do
      let(:routes) { [invalid_route] }

      it "logs an error message and carries on" do
        expect(logger).to receive(:error).with(/Unable/)

        described_class.publish_special_routes
      end
    end

    context "unpublishing a route" do
      let(:routes) { [api_content_route, typeless_route] }

      it "unpublishes the named route" do
        stub_unpublish = stub_request(:post, "#{publishing_api_endpoint}/v2/content/#{typeless_route[:content_id]}/unpublish")
          .with(body: "{\"type\":\"gone\"}")

        described_class.unpublish_one_route(typeless_route[:base_path])

        expect(stub_unpublish).to have_been_requested
      end
    end
  end
end
