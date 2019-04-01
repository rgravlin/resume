# Requirements:
* Vagrant
* VirtualBox

# Build Steps:

    git clone https://github.com/rgravlin/resume.git
    cd resume
    vagrant up
    vagrant ssh
    sudo iptables -P FORWARD ACCEPT
    microk8s.enable dns registry
    
    docker build -t resume:builder . -f Dockerfile.builder
    docker build -t localhost:32000/resume:latest . -f Dockerfile
    docker push localhost:32000/resume:latest

    microk8s.kubectl run resume \
      --image localhost:32000/resume \
      --env="AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
      --env="AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
      --env="AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" 

    microk8s.kubectl expose deployment resume \
      --port 80 \
      --target-port 4570 \
      --type ClusterIP \
      --selector=run=resume \
      --name resume    

    curl -s $(microk8s.kubectl get svc/resume -o json | jq -r .spec.clusterIP)/resume 
