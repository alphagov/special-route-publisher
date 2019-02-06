require_relative '../../lib/special_route_publisher'
require 'securerandom'

RSpec.describe SpecialRoutePublisher, '#publish_special_routes' do
  let(:publishing_api_endpoint) do
    Plek.find('publishing-api')
  end

  let(:logger) do
    double('logger')
  end

  let(:api_content_entry) do
    [
      {
        content_id: '16ca5ac1-7df5-4137-9f83-0270fcfc8bb5',
        base_path: '/api/content',
        title: 'Content API',
        description: 'API exposing all content on GOV.UK.',
        type: 'prefix',
        publishing_app: 'special-route-publisher',
        rendering_app: 'content-store'
      }
    ]
  end

  let(:invalid_entry) do
    [
      {
        content_id: SecureRandom.uuid,
        base_path: '/something-that-doesnt-matter'
      }
    ]
  end

  before do
    allow(Logger).to receive(:new).and_return(logger)
  end

  context 'with a valid entry in special_routes.yaml' do
    before do
      allow(SpecialRoutePublisher).to receive(:load_special_routes).and_return(api_content_entry)
    end

    it 'calls the Publishing API to reserve a path, put content and publish it' do
      stub_put_path = stub_request(:put, "#{publishing_api_endpoint}/paths#{api_content_entry[0].fetch(:base_path)}").
      with(body: "{\"publishing_app\":\"special-route-publisher\",\"override_existing\":true}")
      stub_put_content = stub_request(:put, "#{publishing_api_endpoint}/v2/content/#{api_content_entry[0].fetch(:content_id)}")
      stub_publish_content = stub_request(:post, "#{publishing_api_endpoint}/v2/content/#{api_content_entry[0].fetch(:content_id)}/publish").
      with(body: "{\"update_type\":null}")

      expect(logger).to receive(:info).with(/Publishing/)

      SpecialRoutePublisher.publish_special_routes

      expect(stub_put_path).to have_been_requested
      expect(stub_put_content).to have_been_requested
      expect(stub_publish_content).to have_been_requested
    end
  end

  context 'with an invalid entry in special_routes.yaml' do
    before do
      allow(SpecialRoutePublisher).to receive(:load_special_routes).and_return(invalid_entry)
    end

    it 'logs an error message and carries on' do
      expect(logger).to receive(:error).with(/Unable/)

      SpecialRoutePublisher.publish_special_routes
    end
  end
end
