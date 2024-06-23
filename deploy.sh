#!/bin/bash

STACK_NAME=hello-world-stack
REGION=us-west-2
S3_BUCKET=lr-bucket-s3
TEMPLATE_FILE=template.yaml

# Eliminar el stack si está en estado ROLLBACK_COMPLETE
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION | grep -q "ROLLBACK_COMPLETE"; then
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
    echo "Waiting for stack deletion to complete..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION
fi

# Crear el bucket de S3 si no existe
if ! aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
  aws s3 mb s3://$S3_BUCKET --region $REGION
  echo "S3 bucket created: $S3_BUCKET"
fi

# Subir el código de Lambda al bucket de S3
aws s3 cp lambda_function.zip s3://$S3_BUCKET/

# Desplegar la plantilla
aws cloudformation deploy --template-file $TEMPLATE_FILE --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --region $REGION
