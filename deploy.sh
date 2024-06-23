#!/bin/bash

STACK_NAME=hello-world-stack
REGION=us-west-2
TEMPLATE_FILE=template.yaml
S3_BUCKET=YOUR_S3_BUCKET  # Reemplaza con el nombre de tu bucket S3

aws cloudformation package --template-file $TEMPLATE_FILE --s3-bucket $S3_BUCKET --output-template-file packaged.yaml --region $REGION
aws cloudformation deploy --template-file packaged.yaml --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --region $REGION
