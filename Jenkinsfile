pipeline {
  agent any

  environment {
    IMAGE_NAME = 'your-dockerhub-username/ensf400-app'
    COMMIT_HASH = ''
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          COMMIT_HASH = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
        }
      }
    }

    stage('Build WAR') {
      steps {
        sh './gradlew clean war'
      }
    }

    stage('Unit Tests') {
      steps {
        sh './gradlew test'
      }
      post {
        always {
          junit 'build/test-results/test/*.xml'
        }
      }
    }

    stage('Static Code Analysis') {
      steps {
        sh './gradlew sonarqube'
        // Optional: wait or verify quality gate
      }
    }

    stage('Security Analysis') {
      steps {
        sh './gradlew dependencyCheckAnalyze'
      }
    }

    stage('Performance Testing') {
      steps {
        sh './gradlew runPerfTests'
      }
    }

    stage('Generate Javadocs') {
      steps {
        sh './gradlew javadoc'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          def imageTag = "${IMAGE_NAME}:${COMMIT_HASH}"
          sh "docker build -t ${imageTag} ."
        }
      }
    }

    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          script {
            def imageTag = "${IMAGE_NAME}:${COMMIT_HASH}"
            sh '''
              echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
              docker push ''' + imageTag
          }
        }
      }
    }

    stage('Deploy (Optional)') {
      steps {
        echo 'Simulating deploy to production...'
        sh 'sleep 5'
      }
    }
  }
}
