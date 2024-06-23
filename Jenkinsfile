pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-west-2'
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
                    def bucketExists = sh(script: "aws s3api head-bucket --bucket $S3_BUCKET", returnStatus: true) == 0
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
                    def stackExists = sh(script: "aws cloudformation describe-stacks --stack-name $CF_STACK_NAME", returnStatus: true) == 0
                    if (stackExists) {
                        echo 'Stack exists, updating...'
                        sh '''
                        aws cloudformation update-stack \
                            --stack-name $CF_STACK_NAME \
                            --template-body file://template.yaml \
                            --capabilities CAPABILITY_NAMED_IAM \
                            --parameters ParameterKey=LambdaS3Bucket,ParameterValue=$S3_BUCKET
                        '''
                    } else {
                        echo 'Stack does not exist, creating...'
                        sh '''
                        aws cloudformation create-stack \
                            --stack-name $CF_STACK_NAME \
                            --template-body file://template.yaml \
                            --capabilities CAPABILITY_NAMED_IAM \
                            --parameters ParameterKey=LambdaS3Bucket,ParameterValue=$S3_BUCKET
                        '''
                    }
                    sh 'aws cloudformation wait stack-create-complete --stack-name $CF_STACK_NAME'
                }
            }
        }

        stage('Add Lambda Permission') {
            steps {
                script {
                    def functionName = sh(script: "aws cloudformation describe-stack-resources --stack-name $CF_STACK_NAME --query \"StackResources[?ResourceType=='AWS::Lambda::Function'].PhysicalResourceId\" --output text", returnStdout: true).trim()
                    echo "Lambda Function Name: ${functionName}"
                    
                    def statementId = "apigateway-access-${System.currentTimeMillis()}"

                    sh "aws lambda add-permission --function-name ${functionName} --principal apigateway.amazonaws.com --statement-id ${statementId} --action lambda:InvokeFunction --region $AWS_DEFAULT_REGION"
                }
            }
        }
    }
}
