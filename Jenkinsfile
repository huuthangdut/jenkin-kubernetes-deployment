pipeline {

  environment {
    dockerimagename = "huuthangdut/react-app"
    dockerImage = ""
  }

  agent any

  stages {

    stage('Checkout Source') {
      environment {
          registryCredential = 'github-credentials'
      }
      steps {
        git branch: 'main',
          credentialsId: 'github-credentials', // Specify the ID of the GitHub credentials configured in Jenkins
          url: 'https://github.com/huuthangdut/jenkin-kubernetes-deployment.git'
      }
    }

    stage('Build image') {
      steps{
        script {
          dockerImage = docker.build dockerimagename
        }
      }
    }

    stage('Pushing Image') {
      environment {
               registryCredential = 'dockerhub-credentials'
           }
      steps{
        script {
          docker.withRegistry( 'https://registry.hub.docker.com', registryCredential ) {
            dockerImage.push("latest")
          }
        }
      }
    }

    stage('Deploying React.js container to Kubernetes') {
      steps {
        script {
          kubernetesDeploy(configs: "deployment.yaml", "service.yaml")
        }
      }
    }

  }

}