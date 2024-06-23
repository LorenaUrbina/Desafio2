#!/bin/bash

STACK_NAME=hello-world-stack
REGION=us-west-2
TEMPLATE_FILE=template.yaml
S3_BUCKET=lr-bucket-s3

# Crear el bucket S3 si no existe
if ! aws s3api head-bucket --bucket $S3_BUCKET 2>/dev/null; then
    aws s3api create-bucket --bucket $S3_BUCKET --region $REGION --create-bucket-configuration LocationConstraint=$REGION
    echo "S3 bucket created: $S3_BUCKET"
fi

# Subir el archivo zip a S3
aws s3 cp lambda_function.zip s3://$S3_BUCKET/

# Desplegar la plantilla
aws cloudformation deploy --template-file $TEMPLATE_FILE --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --region $REGION
