require "gds_api"
require "time"
require "yaml"

class SpecialRoutePublisher
  def self.publish_special_routes
    new.publish_routes(load_special_routes)
  end

  def self.publish_one_route(base_path)
    route = load_special_routes.find { |r| r[:base_path] == base_path }

    if route
      new.publish_routes([route])
    else
      puts "Route needs to be added to /data/special_routes.yaml"
    end
  end

  def self.unpublish_one_route(base_path, alternative_path = nil)
    route = load_special_routes.find { |r| r[:base_path] == base_path }

    if route && alternative_path
      new.publishing_api.unpublish(
        route.fetch(:content_id),
        type: "redirect",
        alternative_path:,
      )
    elsif route
      new.publishing_api.unpublish(
        route.fetch(:content_id),
        type: "gone",
      )
    else
      puts "Route needs to be added to /data/special_routes.yaml"
    end
  end

  def self.publish_homepage
    new.publish_routes(load_homepage)
  end

  def publish_routes(routes)
    time = (Time.respond_to?(:zone) && Time.zone) || Time
    routes.each do |route|
      type = route.fetch(:type, "exact")

      logger.info("Publishing #{type} route #{route.fetch(:base_path)}, routing to #{route.fetch(:rendering_app)}...")

      # Always request a path reservation before publishing the special route,
      # with the flag to override any existing publishing app.
      # This allows for routes that were previously published by other apps to
      # be added to `special_routes.yaml` and "just work".
      publishing_api.put_path(
        route.fetch(:base_path),
        publishing_app: "special-route-publisher",
        override_existing: true,
      )

      publishing_api.put_content(
        route.fetch(:content_id),
        base_path: route.fetch(:base_path),
        document_type: route.fetch(:document_type, "special_route"),
        schema_name: route.fetch(:document_type, "special_route"),
        title: route.fetch(:title),
        description: route.fetch(:description, ""),
        locale: "en",
        details: {},
        routes: [
          {
            path: route.fetch(:base_path),
            type:,
          },
        ],
        publishing_app: "special-route-publisher",
        rendering_app: route.fetch(:rendering_app),
        public_updated_at: time.now.iso8601,
        update_type: route.fetch(:update_type, "major"),
      )

      if route[:links]
        publishing_api.patch_links(
          route.fetch(:content_id),
          links: route[:links],
        )
      end

      publishing_api.publish(route.fetch(:content_id))
    rescue KeyError => e
      logger.error("Unable to publish #{route} due to an error: #{e}")
    end
  end

  def self.load_special_routes
    YAML.load_file("./data/special_routes.yaml")
  end

  def self.load_homepage
    YAML.load_file("./data/homepage.yaml")
  end

  def logger
    @logger ||= Logger.new($stdout)
  end

  def publishing_api
    @publishing_api ||= GdsApi.publishing_api
  end
end
