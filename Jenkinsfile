pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/LorenaUrbina/Desafio2.git'
            }
        }
        stage('Deploy') {
            steps {
                sh 'chmod +x deploy.sh'
                sh './deploy.sh'
            }
        }
        stage('Get API URL') {
            steps {
                script {
                    def apiUrl = sh(script: 'aws cloudformation describe-stacks --stack-name hello-world-stack --region us-west-2 --query "Stacks[0].Outputs[?OutputKey==`HelloWorldApiUrl`].OutputValue" --output text', returnStdout: true).trim()
                    echo "API Endpoint is: ${apiUrl}"
                }
            }
        }
    }
    post {
        success {
            echo 'Deployment process complete.'
        }
    }
}
