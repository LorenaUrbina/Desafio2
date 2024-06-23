#!/bin/bash

STACK_NAME=hello-world-stack
REGION=us-west-2
S3_BUCKET=lr-bucket-s3
TEMPLATE_FILE=template.yaml
ZIP_FILE=lambda_function.zip

# Crear el bucket S3 si no existe
if ! aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'
then
    echo "Creating S3 bucket: $S3_BUCKET"
    aws s3 mb s3://$S3_BUCKET --region $REGION
else
    echo "S3 bucket already exists: $S3_BUCKET"
fi

# Subir el archivo ZIP a S3
echo "Uploading $ZIP_FILE to S3 bucket: $S3_BUCKET"
aws s3 cp $ZIP_FILE s3://$S3_BUCKET/

# Desplegar la plantilla
echo "Deploying CloudFormation stack: $STACK_NAME"
aws cloudformation deploy --template-file $TEMPLATE_FILE --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --region $REGION

# Obtener la URL del API Gateway
API_URL=$(aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION --query 'Stacks[0].Outputs[?OutputKey==`HelloWorldApiUrl`].OutputValue' --output text)
echo "API Endpoint is: $API_URL"
