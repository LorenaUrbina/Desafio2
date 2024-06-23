#!/bin/bash

set -e

BUCKET_NAME="lr-bucket-s3"
REGION="us-west-2"

# Crear el bucket si no existe
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "Bucket $BUCKET_NAME no existe. Creándolo..."
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" --create-bucket-configuration LocationConstraint="$REGION"
  echo "Bucket $BUCKET_NAME creado."
else
  echo "Bucket $BUCKET_NAME ya existe."
fi

# Subir el archivo lambda_function.zip al bucket
aws s3 cp lambda_function.zip s3://$BUCKET_NAME/
echo "Archivo lambda_function.zip subido a s3://$BUCKET_NAME/"
