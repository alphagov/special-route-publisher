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

task default: [:spec]
