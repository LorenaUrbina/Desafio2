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
                sh '''
                zip -r9 lambda_function.zip .
                aws s3 cp lambda_function.zip s3://$S3_BUCKET/
                '''
            }
        }

        stage('Deploy with CloudFormation') {
            steps {
                sh '''
                aws cloudformation deploy \
                    --template-file template.yaml \
                    --stack-name $CF_STACK_NAME \
                    --capabilities CAPABILITY_NAMED_IAM \
                    --parameter-overrides LambdaS3Bucket=$S3_BUCKET
                '''
            }
        }
    }
}
