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

## Publishing routes locally

_You will need to start Publishing API and Content Store to run the following commands locally._

To publish all routes:

```
env PUBLISHING_API_BEARER_TOKEN=abc bundle exec rake publish_special_routes
```

To publish one route:

```
env PUBLISHING_API_BEARER_TOKEN=abc bundle exec rake publish_one_route["/base-path"]
```

## Publishing routes on EKS

As special-route-publisher isn't deployed anywhere we can't use the usual instructions for [running a rake task on EKS](https://docs.publishing.service.gov.uk/manual/running-rake-tasks.html#run-a-rake-task-on-eks)

First you need to set your aws user, and the enviroment you want to publish in. For example:

```
eval $(gds aws govuk-integration-poweruser -e --art 8h)
export AWS_REGION=eu-west-1
kubectl config use-context integration
```

Then you need to get the publishing-api bearer token from secrets:

```
cd govuk-secrets/puppet_aws

env=integration

token=$(bundle exec rake eyaml:decrypt_value\[$env,govuk_jenkins::jobs::publish_special_routes::publishing_api_bearer_token])
```

Then, run the rake task in a new kubernetes pod. As special-route-publisher isn't deployed anywhere, you need to specify the image name. Also you must make sure that `PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS` and `PUBLISHING_API_BEARER_TOKEN` are set:

```
kubectl run -napps --image 172025368201.dkr.ecr.eu-west-1.amazonaws.com/special-route-publisher ${USER/./-}-special-route-pub -- sh -c "GOVUK_APP_DOMAIN= PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS=1 PUBLISHING_API_BEARER_TOKEN=$token rake publish_special_routes"
```

Use the `[]` notation to pass parameters to a task, for example:

```
kubectl run -napps --image 172025368201.dkr.ecr.eu-west-1.amazonaws.com/special-route-publisher ${USER/./-}-special-route-pub -- sh -c "GOVUK_APP_DOMAIN= PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS=1 PUBLISHING_API_BEARER_TOKEN=$token rake publish_one_special_route['/government/history/past-chancellors']"
```

Finally, delete your pod when it has finished running:

```
kubectl run -napps delete pod ${USER/./-}-special-route-pub
```

N.B. In these examples, `$USER` is just being used to set the name of the kubernetes pod. (Note that pod names cannot contain a period, so we substitute a dash for any periods in your username)

## Deployment

This app doesn't run anywhere. When it goes through the github deploy action, the image is published to the image registry. When this happens from the main branch,
the image is tagged as 'latest' and will be the version picked when you spin the container up as detailed in the "Publishing routes on EKS" section above.

## Testing a branch on integration

If you want to test publishing special routes from code that is not merged into the main branch, first deploy your branch using the normal github actions flow. Note as above that this does not actually deploy an application anywhere.

Grab the release tag for the pushed image from the github actions logs. This should be listed at the end of the "Push image" section, and will look something like: `release-[some-sha]`

Then follow the instructions in the "Publishing routes on EKS" section above, but when you spin up the new pod, append the release tag to the end of the image name, separated by a colon.

E.g. to publish all the routes:

```
kubectl run -napps --image 172025368201.dkr.ecr.eu-west-1.amazonaws.com/special-route-publisher:release-[some-sha] ${USER/./-}-special-route-pub -- sh -c "GOVUK_APP_DOMAIN= PLEK_USE_HTTP_FOR_SINGLE_LABEL_DOMAINS=1 PUBLISHING_API_BEARER_TOKEN=$token rake publish_special_routes"
```

## Licence

[MIT License](LICENCE)
