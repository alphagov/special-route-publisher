require_relative 'lib/special_route_publisher'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

desc 'Publish special routes to the Publishing API'
task :publish_special_routes do
  SpecialRoutePublisher.publish_special_routes
end

desc 'Publish coronavirus routes to the Publishing API with a major update'
task :publish_coronavirus_routes do
  SpecialRoutePublisher.publish_coronavirus_routes
end

desc 'Publish coronavirus routes to the Publishing API with a minor update'
task :minor_publish_coronavirus_routes do
  SpecialRoutePublisher.minor_update_coronavirus_routes
end

task default: [:spec]
