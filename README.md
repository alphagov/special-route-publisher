# Special Route Publisher

Publishes special routes to the Publishing API on behalf of other apps.

## Technical documentation

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the tests and rake commands on your local machine. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

## Running the test suite

```
bundle exec rake
```

## Adding new routes

Add an entry to `/data/special_routes.yaml`, for example:

```
- :content_id: 'c1f08359-21f7-49c1-8811-54bf6690b6a3'
  :base_path: '/account/home'
  :title: 'Account home page'
  :rendering_app: 'frontend'
```

You can generate a new value for `content_id` by running `SecureRandom.uuid` in a ruby console.

### NOTE

If there is any other route published at that base_path by another app, that will get overridden by [routes published here](https://github.com/alphagov/special-route-publisher/blob/a74101c47fffd80123efbfd1d095398a40bdc594/lib/special_route_publisher.rb#L46-L54).

## Publishing routes

_You will need to start Publishing API and Content Store to run the following commands locally._

To publish all routes:

```
env PUBLISHING_API_BEARER_TOKEN=abc bundle exec rake publish_special_routes
```

To publish one route:

```
env PUBLISHING_API_BEARER_TOKEN=abc bundle exec rake publish_one_route["/base-path"]
```

See "[Publish special routes](https://docs.publishing.service.gov.uk/manual/publish-special-routes.html)" for quick links to the Jenkins jobs that invoke the rake tasks above.

## Deployment

This app isn't deployed anywhere. The repository is [cloned by the Jenkins jobs](https://github.com/alphagov/govuk-puppet/blob/30e80a538682dec8d6c3ed77c71c22596ba61347/modules/govuk_jenkins/templates/jobs/publish_special_routes.yaml.erb#L6), so any new changes are immediately picked up by the rake tasks.

## Licence

[MIT License](LICENCE)
