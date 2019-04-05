[![Maintainability](https://api.codeclimate.com/v1/badges/c8dece56339c39096e7f/maintainability)](https://codeclimate.com/github/rgravlin/resume/maintainability)

# NOTE
This will work locally until ECS attempts to pull the container image.  I will be updating this to include a public image so that anyone can run this completely.

# TODO
* Update Terraform ecs.tf, variables.tf, and templates to use variables
* Test full build and deployment process
* Change to correct multi-stage build to reduce final container size (Ruby is large)

# Requirements
* Vagrant
* VirtualBox

# HTTP Streaming
* Had to disable proxy_buffering in NGINX (behavior looks like lag)

# High level diagrams

![Resume Runner Infrastructure](https://user-images.githubusercontent.com/47820720/55648770-2dc09580-57af-11e9-9400-fee98c68c351.png)

![Resume Runner Resource Creation](https://user-images.githubusercontent.com/47820720/55648790-3c0eb180-57af-11e9-9eb4-ca48f45a611d.png)

# Build Steps:
    $ local
    git clone https://github.com/rgravlin/resume.git
    cd resume
    vi variables.tf (inject your AWS account information)
    vagrant up
    vagrant ssh
    
    $ vagrant
    export AWS_ACCESS_KEY_ID=<YOUR_KEY_ID>
    export AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_KEY>
    export AWS_DEFAULT_REGION=<YOUR_REGION>
    export APPNS=resume-runner
    export BUILD_REPO=localhost:32000/${APPNS}
    export BUILD_TAG=latest
    cd workspace

    $ vagrant -> docker build -> local kubernetes docker repository
    docker build -t ${BUILD_REPO}:${BUILD_TAG} .
    docker push ${BUILD_REPO}:${BUILD_TAG}

    $ vagrant -> local kubernetes
    microk8s.kubectl run ${APPNS} \
      --image ${BUILD_REPO}:${BUILD_TAG} \
      --env="AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
      --env="AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
      --env="AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" \
      --env="HOME=/usr/app" \
      --labels="app=${APPNS}"

    microk8s.kubectl expose deployment ${APPNS} \
      --port 80 \
      --target-port 4570 \
      --type ClusterIP \
      --selector=app=${APPNS} \
      --name ${APPNS} \
      --labels="app=${APPNS}"
    
    $ validate terraform runner (apply)
    curl -s $(microk8s.kubectl get svc/${APPNS} -o jsonpath='{.spec.clusterIP}')/resume

    $ validate terraform runner (destroy)
    curl -s $(microk8s.kubectl get svc/${APPNS} -o jsonpath='{.spec.clusterIP}')/resume
