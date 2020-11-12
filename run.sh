#!/usr/bin/env sh

%{ if always_pull ~}
# Pull the image first.
docker pull ${image}
%{ endif ~}

# Remove the container if there is one already.
docker stop run
docker rm -f run

# Run the container.
docker run \
  -d \
  --rm \
  --name run \
  --log-driver journald \
  %{ for key, val in env ~}-e ${key}=${val} \
  %{ endfor ~}
%{ for pair in ports ~}-p ${pair.port}:${pair.port}${lower(pair.protocol) == "udp" ? "/udp" : ""} \
  %{ endfor ~}
%{ for name, path in volumes }--mount "type=volume,source=${name},destination=${path}" \
  %{ endfor ~}
${image}
