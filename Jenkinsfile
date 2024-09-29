pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker_credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                script {
                    sh '''
                    echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin
                    if [ "$(docker ps -q -f name=registry)" ]; then
                        docker stop registry
                        docker rm registry
                        docker run -d -p 5000:5000 --name registry registry:latest
                    else
                        docker run -d -p 5000:5000 --name registry registry:latest
                    fi
                    docker build . -t localhost:5000/mini-proj:stable --build-arg VERSION=stable
                    docker push localhost:5000/mini-proj:stable
                    docker build . -t localhost:5000/mini-proj:canary --build-arg VERSION=canary
                    docker push localhost:5000/mini-proj:canary
                    '''
                }
                }
            }
        }
        stage('Deploy') {
            steps {
                    withKubeConfig(caCertificate: "${KUBE_CERT}", clusterName: 'kubernetes', contextName: 'kubernetes-admin@kubernetes', credentialsId: 'my-kube-config-credentials', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://jump-host:6443') {
                    sh 'kubectl apply -f pv-definition.yaml'
                    sh 'kubectl apply -f pvc-definition.yaml'
                    sh 'kubectl apply -f deployment-stable.yaml'
                    sh 'kubectl apply -f deployment-canary.yaml'
                    }
            }
        }
    }
}
