#!/bin/bash
set -e

REGION="${AWS_DEFAULT_REGION:-us-east-1}"

create_table_if_not_exists() {
  local table_name="$1"
  shift

  if awslocal dynamodb describe-table --table-name "$table_name" --region "$REGION" > /dev/null 2>&1; then
    echo "Table '$table_name' already exists, skipping."
    return
  fi

  echo "Creating table '$table_name'..."
  awslocal dynamodb create-table --table-name "$table_name" --region "$REGION" "$@"
  echo "Table '$table_name' created."
}

# Sealify
create_table_if_not_exists certificates \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
    AttributeName=serial_number,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --global-secondary-indexes \
    "IndexName=SerialNumberIndex,KeySchema=[{AttributeName=serial_number,KeyType=HASH}],Projection={ProjectionType=ALL}" \
  --billing-mode PAY_PER_REQUEST

# SRI Integrator
create_table_if_not_exists invoices \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
    AttributeName=invoiceId,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --global-secondary-indexes \
    "IndexName=InvoiceIdIndex,KeySchema=[{AttributeName=invoiceId,KeyType=HASH}],Projection={ProjectionType=ALL}" \
  --billing-mode PAY_PER_REQUEST
