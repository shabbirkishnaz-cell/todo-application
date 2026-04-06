#!/usr/bin/env bash
set -euo pipefail

REGION="us-east-1"
CLUSTER="eksdemo2"

echo "Updating kubeconfig..."
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"

echo "Waiting for argocd to be reachable (optional)..."
kubectl get ns argocd >/dev/null 2>&1 || true

echo "Done."
