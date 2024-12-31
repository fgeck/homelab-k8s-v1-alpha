#!/bin/bash

helm uninstall media
helm uninstall monitoring
kubectl -n longhorn-system patch settings.longhorn.io deleting-confirmation-flag --type=merge -p '{"value": "true"}'
helm uninstall edge-persistence-setup
helm uninstall bootstrap
