pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
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
                    def apiUrl = sh(script: "aws cloudformation describe-stacks --stack-name hello-world-stack --query Stacks[0].Outputs[?OutputKey=='HelloWorldApiUrl'].OutputValue --output text", returnStdout: true).trim()
                    echo "API Endpoint is: ${apiUrl}"
                }
            }
        }
    }
    post {
        always {
            echo 'Deployment process complete.'
        }
    }
}
