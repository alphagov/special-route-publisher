require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

desc 'Run govuk-lint with similar params to CI'
task :lint do
  sh "bundle exec govuk-lint-ruby --format clang"
end

# rubocop:disable Metrics/BlockLength
desc 'Publish special routes to the Publishing API'
task :publish_special_routes do
  require 'gds_api/publishing_api_v2'
  require 'time'
  require 'yaml'

  logger = Logger.new(STDOUT)
  publishing_api = GdsApi::PublishingApiV2.new(
    Plek.find('publishing-api'),
    bearer_token: ENV.fetch('PUBLISHING_API_BEARER_TOKEN', 'example')
  )
  time = (Time.respond_to?(:zone) && Time.zone) || Time
  special_routes = YAML.load_file('special_routes.yaml')

  special_routes.each do |route|
    logger.info("Publishing #{route.fetch(:type)} route #{route.fetch(:base_path)}, routing to #{route.fetch(:rendering_app)}...")

    # Always request a path reservation before publishing the special route,
    # with the flag to override any existing publishing app.
    # This allows for routes that were previously published by other apps to
    # be added to `special_routes.yaml` and "just work".
    publishing_api.put_path(
      route.fetch(:base_path),
      publishing_app: route.fetch(:publishing_app),
      override_existing: true
    )

    publishing_api.put_content(
      route.fetch(:content_id),
      base_path: route.fetch(:base_path),
      document_type: 'special_route',
      schema_name: 'special_route',
      title: route.fetch(:title),
      description: route.fetch(:description, ''),
      locale: 'en',
      details: {},
      routes: [
        {
          path: route.fetch(:base_path),
          type: route.fetch(:type),
        }
      ],
      publishing_app: route.fetch(:publishing_app),
      rendering_app: route.fetch(:rendering_app),
      public_updated_at: time.now.iso8601,
      update_type: route.fetch(:update_type, 'major')
    )

    publishing_api.publish(route.fetch(:content_id))
  end
end
# rubocop:enable Metrics/BlockLength

task default: [:spec]
