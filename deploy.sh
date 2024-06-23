#!/bin/bash

# Variables
STACK_NAME="hello-world-stack"
REGION="us-west-2"
S3_BUCKET="nombre-de-tu-bucket-s3"
TEMPLATE_FILE="template.yaml"  # Asegúrate de que esto coincida con el nombre real del archivo

# Verificar si el bucket de S3 existe y crearlo si no
if aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
  echo "Creating S3 bucket: $S3_BUCKET"
  aws s3 mb s3://$S3_BUCKET --region $REGION
else
  echo "S3 bucket already exists: $S3_BUCKET"
fi

# Subir el archivo zip de Lambda al S3
aws s3 cp lambda_function.zip s3://$S3_BUCKET/

# Desplegar la plantilla de CloudFormation
aws cloudformation deploy --template-file $TEMPLATE_FILE --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --region $REGION
