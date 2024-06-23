#!/bin/bash

STACK_NAME=hello-world-stack
REGION=us-west-2
TEMPLATE_FILE=template.yaml

# Eliminar el stack si está en estado ROLLBACK_COMPLETE
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION | grep -q "ROLLBACK_COMPLETE"; then
    aws cloudformation delete-stack --stack-name $STACK_NAME --region $REGION
    echo "Waiting for stack deletion to complete..."
    aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME --region $REGION
fi

# Desplegar la plantilla
aws cloudformation deploy --template-file $TEMPLATE_FILE --stack-name $STACK_NAME --capabilities CAPABILITY_IAM --region $REGION
