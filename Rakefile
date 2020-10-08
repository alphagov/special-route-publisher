require_relative "lib/special_route_publisher"

desc "Publish special routes to the Publishing API"
task :publish_special_routes do
  SpecialRoutePublisher.publish_special_routes
end

desc "Publish a single special route to the Publishing API"
task :publish_one_special_route, [:base_path] => :environment do |_, args|
  SpecialRoutePublisher.publish_one_route(args.base_path)
end

desc "Run tests"
task :spec do
  sh "bundle exec rspec"
end

desc "Lint ruby"
task :lint do
  sh "bundle exec rubocop --format clang"
end

task default: %i[spec lint]
