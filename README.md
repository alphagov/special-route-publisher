# Special Route Publisher

Publishes special routes to the Publishing API on behalf of other apps.

## Technical documentation

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the tests and rake commands on your local machine. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

## Running the test suite

```
bundle exec rake
```

## Running the rake tasks

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
