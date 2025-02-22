pipeline {
    agent any
    environment {
        SONARQUBE_SERVER = 'Sonar' // Match the name configured in Jenkins
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Swarupla/LOC.git'
            }
        }
        
        stage('Build') {
            steps {
                sh 'mvn clean package' // Adjust for your build tool
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarQube') { 
                    sh 'mvn sonar:sonar'  // Adjust based on your build tool
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        error "Pipeline failed due to quality gate failure: ${qg.status}"
                    }
                }
            }
        }
    }
}
