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

## Licence

[MIT License](LICENCE)
