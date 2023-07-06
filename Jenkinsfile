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
        containers:
          - name: jnlp
            image: jenkins/jnlp-agent:latest
            args: ["${JENKINS_URL}", "${AGENT_SECRET}", "${AGENT_NAME}"]
            resources:
              requests:
                cpu: 500m
                memory: 1Gi
              limits:
                cpu: 1
                memory: 2Gi
            volumeMounts:
              - mountPath: /var/run/docker.sock
                name: docker-sock
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
        container('jnlp') {
          script {
            sh 'docker build -t ${DOCKER_IMAGE_NAME}:latest .'
          }
        }
      }
    }

    stage('Pushing Image') {
      steps {
        container('jnlp') {
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
        container('jnlp') {
          withCredentials([file(credentialsId: 'kube-config-admin', variable: 'TMPKUBECONFIG')]) {
            sh 'cat \$TMPKUBECONFIG'
            sh 'cp \$TMPKUBECONFIG /.kube/config'
            sh 'kubectl apply -f deployment.yaml'
          }
        }
      }
    }

  }

}