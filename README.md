# README

Run `OTEL_TRACES_EXPORTER='otlp' OTEL_EXPORTER_OTLP_ENDPOINT="http://localhost:4318" bundle exec rails s`
or if you have loaded .env.development (see below), `be rails s`

## Localstack s3 bucket 
To up s3 : `docker-compose up -d`, then `source .env.development` will source needed local env vars and create the bucket.

URL of bucket : http://dice-app-bucket.s3.localhost.localstack.cloud:4566

To list files in bucket: `aws --endpoint-url=$LOCALSTACK_URL s3 ls s3://dice-app-bucket`
