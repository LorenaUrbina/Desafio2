pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-west-2'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/LorenaUrbina/Desafio2.git', branch: 'main'
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
                    def apiUrl = sh(script: "aws cloudformation describe-stacks --stack-name hello-world-stack --query 'Stacks[0].Outputs[?OutputKey==`HelloWorldApiUrl`].OutputValue' --output text", returnStdout: true).trim()
                    echo "API Endpoint is: ${apiUrl}"
                    sh "curl -X GET ${apiUrl}" // Esto imprimirá la respuesta de la API
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
