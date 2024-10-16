pipeline {
  agent { label 'jdk17' }
  options {
    disableConcurrentBuilds()
  }
  environment {
    project = 'jenkins-master'
    tag = 'default'
    commitNum = 'default'
  }
  triggers {
    pollSCM('H/5 * * * *')
  }

  stages{
    stage('Preparation') {
      steps {
        echo "STARTED:\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})"
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'git-hub', url: 'https://github.com/minotaur423/jenkins-master.git']])
        script {
          branchformatted="${GIT_BRANCH}".toUpperCase().replaceAll(/[^A-Z0-9]/, ".")
          version = "${branchformatted}-${BUILD_ID}."+"${env.GIT_COMMIT}".substring(0,5)
          latestversion = "${branchformatted}-latest"
          sh "echo ${version}/${latestversion}"
        }
      }
    }
    stage('Build Docker') {
      steps {
        sh "docker build -t ${ARTIFACTORY_DOCKER_URL}/docker-local/${project}:${version} ."
        sh "docker build -t ${ARTIFACTORY_DOCKER_URL}/docker-local/${project}:${latestversion} ."
      }
    }
    stage('Push Docker') {
      steps {
        sh "docker login -u ${ARTIFACTORY_DOCKER_USER} -p ${ARTIFACTORY_DOCKER_PWD} ${ARTIFACTORY_DOCKER_URL}"
        sh "docker push ${ARTIFACTORY_DOCKER_URL}/docker-local/${project}:${version}"
        sh "docker push ${ARTIFACTORY_DOCKER_URL}/docker-local/${project}:${latestversion}"
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
