#!/usr/bin/env sh

# Get the details.
project_id="$(curl -H "Metadata-Flavor: Google" metadata.google.internal/computeMetadata/v1/project/project-id)"

# Remove the container if there is one already.
docker rm -f fluentd

# Run the container.
docker run \
  -d \
  --rm \
  --name fluentd \
  --log-driver syslog \
  -e PROJECT="$project_id" \
  -e AUTO_CREATE_TABLE=false \
  -p 20001:20001 \
  -v fluentd-data:/fluentd/data \
  garbetjie/fluentd:v1.11-monolog
