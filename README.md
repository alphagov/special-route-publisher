# Special Route Publisher

Publishes special routes to the Publishing API on behalf of other apps.

## Running the rake tasks

To publish all routes:

`PUBLISHING_API_BEARER_TOKEN=abc bundle exec rake publish_special_routes`

To publish one route:

`PUBLISHING_API_BEARER_TOKEN=abc bundle exec rake publish_one_route["/base-path"]`

## Licence

[MIT License](LICENCE)
