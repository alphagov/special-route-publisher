require_relative "lib/special_route_publisher"

begin
  require "rubocop/rake_task"
  require "rspec/core/rake_task"

  RuboCop::RakeTask.new
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
  # These gems will fail to load outside of dev/test environments
end

desc "Publish special routes to the Publishing API"
task :publish_special_routes do
  SpecialRoutePublisher.publish_special_routes
end

desc "Publish a single special route to the Publishing API"
task :publish_one_special_route, [:base_path] do |_, args|
  SpecialRoutePublisher.publish_one_route(args.base_path)
end

desc "Unpublish a single special route, with a type of 'gone' or 'redirect' and unreserve path set to true or false (default)"
task :unpublish_one_special_route, [:base_path, :alternative_path, :unreserve_path] do |_, args|
  unreserve_path = true if args.unreserve_path&.downcase == "true"

  SpecialRoutePublisher.unpublish_one_route(args.base_path, args.alternative_path, unreserve_path:)
end

task default: %i[rubocop spec]
