pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-west-1'
        S3_BUCKET = 'lr-bucket-s3'
        CF_STACK_NAME = 'lambda-deployment-stack'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/LorenaUrbina/Desafio2.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'pip install -r requirements.txt -t .'
            }
        }

        stage('Package Lambda Function') {
            steps {
                sh 'zip -r9 lambda_function.zip .'
            }
        }

        stage('Upload to S3') {
            steps {
                script {
                    def bucketExists = sh(script: "aws s3api head-bucket --bucket $S3_BUCKET --region $AWS_DEFAULT_REGION", returnStatus: true) == 0
                    if (!bucketExists) {
                        echo 'Bucket does not exist. Creating...'
                        sh "aws s3api create-bucket --bucket $S3_BUCKET --region $AWS_DEFAULT_REGION --create-bucket-configuration LocationConstraint=$AWS_DEFAULT_REGION"
                    } else {
                        echo 'Bucket exists.'
                    }
                    sh "aws s3 cp lambda_function.zip s3://$S3_BUCKET/"
                }
            }
        }

        stage('Deploy with CloudFormation') {
            steps {
                script {
                    def stackExists = sh(script: "aws cloudformation describe-stacks --stack-name $CF_STACK_NAME --region $AWS_DEFAULT_REGION", returnStatus: true) == 0
                    if (stackExists) {
                        def stackStatus = sh(script: "aws cloudformation describe-stacks --stack-name $CF_STACK_NAME --region $AWS_DEFAULT_REGION --query 'Stacks[0].StackStatus' --output text", returnStdout: true).trim()
                        if (stackStatus == "ROLLBACK_COMPLETE") {
                            echo 'Stack is in ROLLBACK_COMPLETE state, deleting...'
                            sh "aws cloudformation delete-stack --stack-name $CF_STACK_NAME --region $AWS_DEFAULT_REGION"
                            sh "aws cloudformation wait stack-delete-complete --stack-name $CF_STACK_NAME --region $AWS_DEFAULT_REGION"
                            echo 'Stack deleted, creating...'
                            sh '''
                            aws cloudformation create-stack \
                                --stack-name $CF_STACK_NAME \
                                --template-body file://template.yaml \
                                --capabilities CAPABILITY_NAMED_IAM \
                                --parameters ParameterKey=LambdaS3Bucket,ParameterValue=$S3_BUCKET \
                                --region $AWS_DEFAULT_REGION
                            '''
                        } else {
                            echo 'Stack exists, updating...'
                            sh '''
                            aws cloudformation update-stack \
                                --stack-name $CF_STACK_NAME \
                                --template-body file://template.yaml \
                                --capabilities CAPABILITY_NAMED_IAM \
                                --parameters ParameterKey=LambdaS3Bucket,ParameterValue=$S3_BUCKET \
                                --region $AWS_DEFAULT_REGION
                            '''
                        }
                    } else {
                        echo 'Stack does not exist, creating...'
                        sh '''
                        aws cloudformation create-stack \
                            --stack-name $CF_STACK_NAME \
                            --template-body file://template.yaml \
                            --capabilities CAPABILITY_NAMED_IAM \
                            --parameters ParameterKey=LambdaS3Bucket,ParameterValue=$S3_BUCKET \
                            --region $AWS_DEFAULT_REGION
                        '''
                    }
                    sh "aws cloudformation wait stack-create-complete --stack-name $CF_STACK_NAME --region $AWS_DEFAULT_REGION"
                }
            }
        }

        stage('Add Lambda Permission') {
            steps {
                script {
                    def functionName = sh(script: "aws cloudformation describe-stack-resources --stack-name $CF_STACK_NAME --region $AWS_DEFAULT_REGION --query \"StackResources[?ResourceType=='AWS::Lambda::Function'].PhysicalResourceId\" --output text", returnStdout: true).trim()
                    echo "Lambda Function Name: ${functionName}"
                    
                    def statementId = "apigateway-access-${System.currentTimeMillis()}"

                    sh "aws lambda add-permission --function-name ${functionName} --principal apigateway.amazonaws.com --statement-id ${statementId} --action lambda:InvokeFunction --region $AWS_DEFAULT_REGION"
                }
            }
        }
    }
}
