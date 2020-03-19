require "gds_api/publishing_api_v2"
require "time"
require "yaml"

class SpecialRoutePublisher
  def self.publish_special_routes
    special_routes = load_special_routes
    new.publish_routes(special_routes)
  end

  def publish_routes(routes)
    time = (Time.respond_to?(:zone) && Time.zone) || Time

    # rubocop:disable Metrics/BlockLength
    routes.each do |route|
      begin
        type = route.fetch(:type, "exact")

        logger.info("Publishing #{type} route #{route.fetch(:base_path)}, routing to #{route.fetch(:rendering_app)}...")

        # Always request a path reservation before publishing the special route,
        # with the flag to override any existing publishing app.
        # This allows for routes that were previously published by other apps to
        # be added to `special_routes.yaml` and "just work".
        publishing_api.put_path(
          route.fetch(:base_path),
          publishing_app: "special-route-publisher",
          override_existing: true,
        )

        publishing_api.put_content(
          route.fetch(:content_id),
          base_path: route.fetch(:base_path),
          document_type: "special_route",
          schema_name: "special_route",
          title: route.fetch(:title),
          description: route.fetch(:description, ""),
          locale: "en",
          details: {},
          routes: [
            {
              path: route.fetch(:base_path),
              type: type,
            },
          ],
          publishing_app: "special-route-publisher",
          rendering_app: route.fetch(:rendering_app),
          public_updated_at: time.now.iso8601,
          update_type: route.fetch(:update_type, "major"),
        )

        publishing_api.publish(route.fetch(:content_id))
      rescue KeyError => e
        logger.error("Unable to publish #{route} due to an error: #{e}")
      end
    end
    # rubocop:enable Metrics/BlockLength
  end

  def self.load_special_routes
    YAML.load_file("./data/special_routes.yaml")
  end
  private_class_method :load_special_routes

  def logger
    @logger ||= Logger.new(STDOUT)
  end

  def publishing_api
    @publishing_api ||= GdsApi::PublishingApiV2.new(
      Plek.find("publishing-api"),
      bearer_token: ENV.fetch("PUBLISHING_API_BEARER_TOKEN", "example"),
    )
  end
end
