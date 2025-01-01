#!/bin/bash

kubectl config set-context --current --namespace=media
helm uninstall media
kubectl config set-context --current --namespace=monitoring
helm uninstall monitoring
kubectl -n longhorn-system patch settings.longhorn.io deleting-confirmation-flag --type=merge -p '{"value": "true"}'
kubectl config set-context --current --namespace=default
helm uninstall db
kubectl config set-context --current --namespace=kube-system
helm uninstall bootstrap
