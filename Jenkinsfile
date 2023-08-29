pipeline {
  agent { label 'jdk17' }
  options {
    disableConcurrentBuilds()
  }
  environment {
    tag = 'default'
    commitNum = 'default'
    smartDev = '_smart-development'
    buildSet = 'common-docker-images'
    project = 'jenkins-master'
    projectDir = 'docker-image-jenkins-master'
    commonOptions = "-P ci=true -PbuildNumber=${env.BUILD_NUMBER} -P useCloud=false"
    dockerRepoOptions = "-P dockerPrivateRegistry=${ARTIFACTORY_DOCKER_URL} -P dockerPrivateRegistryUsername=${ARTIFACTORY_DOCKER_USER} -P dockerPrivateRegistryPassword=${ARTIFACTORY_DOCKER_PWD} -P dockerPrivateRegistryEmail=${ARTIFACTORY_DOCKER_EMAIL}"
    dockerOptions = "${dockerRepoOptions} -P useDockerPlugin=true"
    gradleCommand = "./gradlew ${GRADLE_PROXY_OPTIONS} :${project}"
  }
  stages{
    stage('Preparation') {
      steps {
        slackSend (color: '#C1C1C1', message: "STARTED:\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})")
        hipchatSend (color: 'GRAY', message: "STARTED:\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})", notify: true, textFormat: true)
        checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: "${env.GIT_COMMIT}"]], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'CleanBeforeCheckout'], [$class: 'RelativeTargetDirectory', relativeTargetDir: "${buildSet}/${projectDir}"], [$class: 'CloneOption', depth: 0, noTags: false, reference: '', shallow: false], [$class: 'LocalBranch', localBranch: "${env.BRANCH_NAME}"]], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'jenkins', url: "https://bitbucket.org/dsnyecm/${projectDir}.git"]]]
        checkout changelog: false, poll: false, scm: [$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: smartDev]], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'jenkins', url: 'https://bitbucket.org/dsnyecm/smart-development.git']]]
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
        dir("_smart-development/build-sets/${buildSet}") {
          timeout(15) {
            sh "${gradleCommand}:buildDockerOnly ${commonOptions} ${dockerOptions} -Ptag=${tag}.${commitNum}"
            sh "${gradleCommand}:buildDockerOnly ${commonOptions} ${dockerOptions} -Ptag=${tag}-latest"
          }
        }
      }
    }
    stage('Push Docker') {
      steps {
        dir("_smart-development/build-sets/${buildSet}") {
          sh "${gradleCommand}:pushDockerOnly ${commonOptions} ${dockerOptions} -Ptag=${tag}.${commitNum}"
          sh "${gradleCommand}:pushDockerOnly ${commonOptions} ${dockerOptions} -Ptag=${tag}-latest"
        }
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
      slackSend (color: '#00FF00', message: "SUCCESSFUL\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\nDocker Image: '${tag}'${latestMessage}\n(${env.BUILD_URL})")
      hipchatSend (color: 'GREEN', message: "SUCCESSFUL\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\nDocker Image: '${tag}'${latestMessage}\n(${env.BUILD_URL})", notify: true, textFormat: true)
    }
    failure {
      slackSend (color: '#FF0000', message: "FAILED\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})")
      hipchatSend (color: 'RED', message: "FAILED\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})", notify: true, textFormat: true)
    }
  }
}
