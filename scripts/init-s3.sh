#!/bin/bash
set -e

REGION="${AWS_DEFAULT_REGION:-us-east-1}"

create_bucket_if_not_exists() {
  local bucket_name="$1"

  if awslocal s3api head-bucket --bucket "$bucket_name" --region "$REGION" 2>/dev/null; then
    echo "Bucket '$bucket_name' already exists, skipping."
    return
  fi

  echo "Creating bucket '$bucket_name'..."
  awslocal s3api create-bucket --bucket "$bucket_name" --region "$REGION"
  echo "Bucket '$bucket_name' created."
}

# SRI Integrator
create_bucket_if_not_exists sri-integrator-certificates
