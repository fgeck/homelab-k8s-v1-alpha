#!/bin/bash

source ./scripts/helper_funcs.sh
assert_tools_installed kubectl helm

gum confirm "Are you sure you want to teardown the whole cluster?" || exit 1

kubectl config set-context --current --namespace=media
helm uninstall media
kubectl config set-context --current --namespace=monitoring
helm uninstall monitoring
kubectl config set-context --current --namespace=security
helm uninstall security
kubectl config set-context --current --namespace=default
helm uninstall persistence
kubectl -n longhorn-system patch settings.longhorn.io deleting-confirmation-flag --type=merge -p '{"value": "true"}'
kubectl config set-context --current --namespace=kube-system
helm uninstall certs
helm uninstall bootstrap
