pipeline {

  environment {
    DOCKER_IMAGE_NAME = "huuthangdut/react-app"
    DOCKER_IMAGE_TAG='v1'
    // VERSION = "${env.BUILD_ID}-${env.GIT_COMMIT}"
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
  }

  agent {
    kubernetes {
      yaml '''
      apiVersion: v1
      kind: Pod
      metadata:
        name: agent 
      spec:
        serviceAccountName: jenkins-admin
        dnsConfig:
          nameservers:
            - 8.8.8.8
        containers:
          - name: docker
            image: docker:latest
            command:
            - cat
            tty: true
            volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
          - name: kubectl
            image: bitnami/kubectl:latest
            command:
            - cat
            tty: true
        imagePullSecrets:
          - name: regcred
        securityContext:
          runAsUser: 0
          runAsGroup: 0
        volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
      '''
    }
  }

  stages {
    stage('Build image') {
      steps{
        container('docker') {
          script {
            sh 'docker build -t ${DOCKER_IMAGE_NAME}:latest .'
          }
        }
      }
    }

    stage('Pushing Image') {
      steps {
        container('docker') {
          script {
            sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            sh 'docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}'
            sh 'docker push ${DOCKER_IMAGE_NAME}:latest'
            sh 'docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}'
          }
        }
      }
    }

    stage('Deploying App to Kubernetes') {
      steps {
        // container('kubectl') {
          // withCredentials([file(credentialsId: 'kube-config-admin', variable: 'TMPKUBECONFIG')]) {
          script {
            // sh 'cat \$TMPKUBECONFIG'
            // sh 'cp \$TMPKUBECONFIG /.kube/config'
            sh 'kubectl apply -f deployment.yaml'
          }
        // }
      }
    }

  }

}