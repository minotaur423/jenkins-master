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
      echo "SUCCESSFUL\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\nDocker Image: '${tag}'${latestMessage}\n(${env.BUILD_URL})"
    }
    failure {
      echo "FAILED\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})"
    }
  }
}
