#!/bin/bash


# Function to remove finalizers from resources of a specific CRD
remove_finalizers_from_crd() {
  crd=$1
  echo "Removing finalizers from CRD: $crd"
  while read -r name; do
    kubectl get "$crd" -n "$namespace" -o jsonpath="{.items[?(@.metadata.name=='$name')].metadata.namespace}" | while read -r namespace; do
      kind=$(kubectl get "$crd" -n "$namespace" -o jsonpath="{.items[?(@.metadata.name=='$name')].kind}")
      echo "Removing finalizers from $kind $name in namespace $namespace"
      kubectl patch "$kind" "$name" -n "$namespace" --type='json' -p='[{"op": "remove", "path": "/metadata/finalizers"}]'
    done
  done
}

# Function to delete a CRD and its associated resources
delete_crd() {
  crd=$1
  echo "Deleting CRD $crd"
  kubectl delete crd "$crd"
}

# Get the CRDs, filter by Cert-Manager, Traefik, and MetalLB using jsonpath and loop
kubectl get crds -o jsonpath='{.items[*].metadata.name}' | \
tr ' ' '\n' | \
grep -E "cert-manager|traefik|metallb" | \
while read -r crd; do
  # Remove finalizers for the given CRD
  echo "Removing finalizers for CRD: $crd"
  remove_finalizers_from_crd "$crd"

  # Optionally, delete the CRD if you want to remove it after finalizer removal
  # Uncomment the next line if you want to delete the CRD after removing finalizers
  # delete_crd "$crd"
done

helm uninstall edge --namespace edge
