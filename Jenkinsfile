pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION = 'us-west-2'
        PATH = "$PATH:/home/lorena/sam-env/bin"
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/LorenaUrbina/Desafio2.git', branch: 'main'
            }
        }
        stage('Build') {
            steps {
                sh '. /home/lorena/sam-env/bin/activate && sam build'
            }
        }
        stage('Deploy') {
            steps {
                sh '. /home/lorena/sam-env/bin/activate && sam deploy --stack-name hello-world-lambda --capabilities CAPABILITY_IAM --region ${AWS_DEFAULT_REGION}'
            }
        }
    }
    post {
        always {
            echo 'Deployment process complete.'
        }
    }
}
