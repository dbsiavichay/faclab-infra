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

# Faclab Invoicing Certificates
create_table_if_not_exists certificates \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
    AttributeName=serial_number,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --global-secondary-indexes \
    "IndexName=SerialNumberIndex,KeySchema=[{AttributeName=serial_number,KeyType=HASH}],Projection={ProjectionType=ALL}" \
  --billing-mode PAY_PER_REQUEST

# Faclab Invoicing Company Config
create_table_if_not_exists company_config \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST

# Faclab Invoicing Invoices
create_table_if_not_exists invoices \
  --attribute-definitions \
    AttributeName=id,AttributeType=S \
    AttributeName=saleId,AttributeType=S \
  --key-schema \
    AttributeName=id,KeyType=HASH \
  --global-secondary-indexes \
    "IndexName=SaleIdIndex,KeySchema=[{AttributeName=saleId,KeyType=HASH}],Projection={ProjectionType=ALL}" \
  --billing-mode PAY_PER_REQUEST
