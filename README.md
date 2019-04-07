[![Maintainability](https://api.codeclimate.com/v1/badges/c8dece56339c39096e7f/maintainability)](https://codeclimate.com/github/rgravlin/resume/maintainability)

# WHY
This project was created to fulfill the following needs:
* Showcase knowledge of the following:

    * Infrastructure design  
    * Infrastructure as code  
    * Local application testing  
    * Documentation  
    * CICD (this part is yet to be implemented)
* Investment of time in myself
* Learn more about local Kubernetes testing
* Learn more about AWS Billing by using tag groups
* Continue learning more about Ruby
* Provide an easy way to update my resume

After the first release, it was obvious to me there was still an issue.  The initial creation of all resources took around 180 seconds.  The way the application was built waited to respond until the command was completed.  This is not acceptable and I set out to find out if it was possible, _without websockets_, to stream HTTP data like tail.  Indeed it is!

I then set out to complete this work which was successful with the [_stream_](https://github.com/rgravlin/resume/tree/stream) branch that was recently merged.  I ran into another issue once I deployed it to my production server.  If you see the diagram below the application is fronted by an NGINX proxy.  What I experienced was something like lag.  It would stream the data, but it would pause, and then come back.  This was due to proxy_buffering within NGINX.

> When buffering is enabled, nginx receives a response from the proxied server as soon as possible, saving it into the buffers set by the proxy_buffer_size and proxy_buffers directives. If the whole response does not fit into memory, a part of it can be saved to a temporary file on the disk. Writing to temporary files is controlled by the proxy_max_temp_file_size and proxy_temp_file_write_size directives.

> When buffering is disabled, the response is passed to a client synchronously, immediately as it is received. nginx will not try to read the whole response from the proxied server. The maximum size of the data that nginx can receive from the server at a time is set by the proxy_buffer_size directive. <http://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_buffering>

Now that the major components are in place and working as expected, the remaining work will be focused on the following:

* Create public NGINX container for hosting the resume PDF artifact
* Create Terraform manifest for AWS CodeBuild that clones this repository and performs the following steps:

    * Builds the resume PDF from the LaTeX source  
    * Builds the NGINX container with the resume PDF artifact  
    * Pushes the NGINX container to AWS ECR
    
## Upcoming Feature 
A full CICD pipeline using the logic below

1. Clone https://github.com/rgravlin/resume.git
2. Run _xelatex latex/resume.tex_ (build PDF artifact)
3. Run _docker build -t ecr.url/resume:latest . -f Dockerfile.resume_ (build Docker artifact)
4. Run _docker push ecr.url/resume:latest_ (next run of tf_runner.rb will use this latest artifact)

## Upcoming Feature
The ability for anyone to clone this repository and successfully build and run the containerized application that will build the same resources I am, but in your own AWS account with your own domain names.

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

![Resume Runner Infrastructure](https://user-images.githubusercontent.com/47820720/55676751-e3234400-58a8-11e9-8949-2105928a67c2.png)

![Resume Runner Resource Creation](https://user-images.githubusercontent.com/47820720/55676752-ecacac00-58a8-11e9-9e82-018a14e56027.png)

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
