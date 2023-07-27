# README

`docker-compose up -d`, then `source .env.development` will source needed local env vars and create the bucket.
Then you can run `bundle exec rails s` and navigate to http://localhost:3000 to upload a file to the s3 bucket.
Navigating then to http://localhost:3000/retrieve will simply create a span with the metadata of the file retrieved from s3.

Traces can be looked at through the jeager UI at http://localhost:16686/

## Localstack s3 bucket 

URL of bucket : http://dice-app-bucket.s3.localhost.localstack.cloud:4566

To list files in bucket: `aws --endpoint-url=$LOCALSTACK_URL s3 ls s3://dice-app-bucket`

# OpenTelemetry

DiceController holds an example of how we could both write the telemetry context to the metadata of an s3 file. See functions upload_to_s3 and retrieve. 

Traces can be looked at through the jeager UI at http://localhost:16686/


