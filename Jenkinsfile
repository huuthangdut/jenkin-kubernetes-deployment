pipeline {

  environment {
    DOCKER_IMAGE_NAME = "huuthangdut/react-app"
    DOCKER_IMAGE_TAG = "${env.GIT_COMMIT}"
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
          - name: node
            image: node:14
            command:
            - cat
            tty: true
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
    stage('Test') {
      steps{
        container('node') {
            script {
              sh 'node -v'
              sh 'npm install'
              sh 'npm run test'
            }
          }
      }
    }

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
        container('kubectl') {
          script {
            sh "sed -i 's|${DOCKER_IMAGE_NAME}:TAG|${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}|' deployment.yaml && kubectl apply -f deployment.yaml"
          }
        }
      }
    }

  }

}

// docker build -t huuthangdut/react-app .
// docker tag huuthangdut/react-app:latest huuthangdut/react-app:latest
// docker push huuthangdut/react-app:latest