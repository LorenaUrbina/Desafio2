#!/bin/bash

# Variables
STACK_NAME="hello-world-stack"
REGION="us-west-2"
S3_BUCKET="lr-bucket-s3"
TEMPLATE_FILE="template.yaml"
ZIP_FILE="lambda_function.zip"
PYTHON_FILE="lambda_function.py"

# Crear el archivo ZIP si no existe
echo "Creating ZIP file from Python lambda function..."
if [ ! -f $ZIP_FILE ]; then
    zip $ZIP_FILE $PYTHON_FILE
else
    echo "ZIP file already exists. Updating..."
    zip -u $ZIP_FILE $PYTHON_FILE
fi

# Crear el bucket de S3 si no existe
echo "Checking if S3 bucket exists..."
if aws s3 ls "s3://$S3_BUCKET" 2>&1 | grep -q 'NoSuchBucket'; then
    echo "Bucket does not exist, creating bucket: $S3_BUCKET"
    aws s3 mb s3://$S3_BUCKET --region $REGION
else
    echo "Bucket already exists: $S3_BUCKET"
fi

# Subir el archivo ZIP a S3
echo "Uploading ZIP file to S3 bucket..."
aws s3 cp $ZIP_FILE s3://$S3_BUCKET/

# Desplegar la plantilla de CloudFormation
echo "Deploying CloudFormation template..."
aws cloudformation deploy --template-file $TEMPLATE_FILE --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --region $REGION

echo "Deployment complete."
