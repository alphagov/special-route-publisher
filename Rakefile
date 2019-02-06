require_relative 'lib/special_route_publisher'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

desc 'Run govuk-lint with similar params to CI'
task :lint do
  sh "bundle exec govuk-lint-ruby --format clang lib spec"
end

desc 'Publish special routes to the Publishing API'
task :publish_special_routes do
  SpecialRoutePublisher.publish_special_routes
end

task default: [:spec, :lint]
