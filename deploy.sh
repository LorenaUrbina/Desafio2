#!/bin/bash

STACK_NAME=hello-world-stack
REGION=us-west-2
TEMPLATE_FILE=template.yaml
S3_BUCKET=lr-bucket-s3
LAMBDA_FILE=lambda_function.zip

# Crear el bucket S3 si no existe
if ! aws s3api head-bucket --bucket $S3_BUCKET 2>/dev/null; then
    aws s3api create-bucket --bucket $S3_BUCKET --region $REGION --create-bucket-configuration LocationConstraint=$REGION
    echo "S3 bucket created: $S3_BUCKET"
fi

# Subir el archivo zip a S3
aws s3 cp $LAMBDA_FILE s3://$S3_BUCKET/$LAMBDA_FILE

# Desplegar la plantilla
aws cloudformation package --template-file $TEMPLATE_FILE --s3-bucket $S3_BUCKET --output-template-file packaged.yaml
aws cloudformation deploy --template-file packaged.yaml --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --region $REGION
