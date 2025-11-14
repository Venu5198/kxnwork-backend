#!/bin/bash
set -e

REGION="${REGION:-us-central1}"
PROJECT="${PROJECT:-kxnwork}"
REPO="backend-repo"
IMAGE="${PROJECT}.svc.${REGION}.docker.pkg.dev/${PROJECT}/${REPO}/backend:latest"

# Install prerequisites
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common

# Install Docker
curl -fsSL https://get.docker.com | sh

# Configure docker to authenticate to Artifact Registry using gcloud credentials
gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet || true

# Pull and run container in restart loop (simple)
docker pull "${IMAGE}" || exit 1

docker run -d --name kxnwork-backend -p 8080:8080 --restart unless-stopped "${IMAGE}"

