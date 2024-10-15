pipeline {
  agent { label 'jdk17' }
  options {
    disableConcurrentBuilds()
  }
  environment {
    tag = 'default'
    commitNum = 'default'
  }
  stages{
    stage('Preparation') {
      steps {
        echo "STARTED:\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})"
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'git-hub', url: 'https://github.com/minotaur423/jenkins-master.git']])
        script {
          commitNum = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          if(env.BRANCH_NAME.contains('/')) {
            tag = sh(script: "echo ${BRANCH_NAME} |awk -F '/' '{print \$2}'", returnStdout: true).trim()
          } else {
            tag = env.BRANCH_NAME
          }
        }
      }
    }
    stage('Build Docker') {
      steps {
          timeout(15) {
            //sh "${gradleCommand}:buildDockerOnly ${commonOptions} ${dockerOptions} -Ptag=${tag}.${commitNum}"
            //sh "${gradleCommand}:buildDockerOnly ${commonOptions} ${dockerOptions} -Ptag=${tag}-latest"
          }
        }
      }
    }
    stage('Push Docker') {
      steps {
        //dir("_smart-development/build-sets/${buildSet}") {
          //sh "${gradleCommand}:pushDockerOnly ${commonOptions} ${dockerOptions} -Ptag=${tag}.${commitNum}"
          //sh "${gradleCommand}:pushDockerOnly ${commonOptions} ${dockerOptions} -Ptag=${tag}-latest"
        //}
      }
    }
  }
  post {
    always {
      script {
        tag = "${tag}"
      }
    }
    success {
      script {
        latestMessage = "\n---also tagged with 'latest'"
      }
      echo "SUCCESSFUL\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\nDocker Image: '${tag}'${latestMessage}\n(${env.BUILD_URL})"
    }
    failure {
      echo "FAILED\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})"
    }
  }
}
