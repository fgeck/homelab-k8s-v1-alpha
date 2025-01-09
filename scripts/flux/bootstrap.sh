!#/bin/bash

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=fleet-infra \
  --branch=main \
  --path=./clusters/fgeck-homelab \
  --personal

flux create secret git github-auth \
    --url=ssh://git@github.com/fgeck/homelab-k8s \
    --private-key-file=/Users/fgeck/.ssh/id_rsa
    