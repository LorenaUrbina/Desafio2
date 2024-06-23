#!/bin/bash

STACK_NAME=hello-world-stack
REGION=us-west-2
TEMPLATE_FILE=template.yaml
S3_BUCKET=your-unique-s3-bucket-name

# Crear un bucket de S3 si no existe
if ! aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null; then
    aws s3api create-bucket --bucket "$S3_BUCKET" --region $REGION --create-bucket-configuration LocationConstraint=$REGION
    echo "S3 bucket created: $S3_BUCKET"
fi

# Eliminar el stack si está en estado ROLLBACK_COMPLETE
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION | grep -q "ROLLBACK_COMPLETE"; then
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
    echo "Waiting for stack deletion to complete..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION
fi

# Subir el código a S3
aws s3 cp lambda_function.zip s3://$S3_BUCKET/

# Empaquetar y desplegar la plantilla
aws cloudformation package --template-file $TEMPLATE_FILE --s3-bucket $S3_BUCKET --output-template-file packaged.yaml --region $REGION
aws cloudformation deploy --template-file
