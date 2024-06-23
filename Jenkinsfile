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
        stage('Build') {
            steps {
                sh 'sam build'
            }
        }
        stage('Deploy') {
            steps {
                sh 'sam deploy --stack-name hello-world-lambda --capabilities CAPABILITY_IAM'
            }
        }
    }
    post {
        always {
            echo 'Deployment process complete.'
        }
    }
}

