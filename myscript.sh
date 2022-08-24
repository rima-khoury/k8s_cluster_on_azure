#!/bin/bash

set -e

RG="k8s1"
DNS_PRFX="k8sCluster"

function download_and_install_requierements {
  echo "install jq, curl"
  sudo apt-get install jq
  sudo apt-get install curl

  #download and install docker
  echo "download and install docker"
  sudo apt-get update
  sudo apt-get install docker.io
  sudo systemctl enable docker
  sudo systemctl start docker

  #download and install az CLI
  echo "download and install az CLI"
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

  #download and install aks-engine
  echo "installing aks-engine version 0.70.0"
  curl -o get-akse.sh https://raw.githubusercontent.com/Azure/aks-engine/master/scripts/get-akse.sh
  chmod 700 get-akse.sh
  ./get-akse.sh --version v0.70.0

  #download and install kubectl
  echo "download and install kubectl tool"
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

  #install pip
  echo "installing python-pip library"
  sudo apt install python-pip

  # install helm following -> https://helm.sh/docs/intro/install/
  echo "download and install helm"
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh

}

#create new resource group
echo "creating resource group ..."
az group create --name "$RG" --location "eastus"
#deploy
aks-engine deploy  --location eastus --resource-group "$RG" --api-model ./kubernetes-azurestack.json --output-directory k8s_cluster  --force-overwrite --auto-suffix
#generate ?
echo "generating api-model ..."
aks-engine generate --api-model kubernetes-azurestack.json
#deploy the cluster
echo "deploy cluster"
az deployment group create -g "$RG" --name "k8sClusterDeployment" --template-file ./k8s_cluster/azuredeploy.json --parameters "./k8s_cluster/azuredeploy.parameters.json"
#add routing table
echo "adding routing table ..."
rt=$(az network route-table list -g $RG -o json | jq -r '.[].id')
vnet_name=$(az network vnet  list -g k8s2 -o table | tail -n +3 | awk '{print $1}')
az network vnet subnet update -n "k8s-subnet" -g $RG --vnet-name $vnet_name --route-table $rt

#export KUBECONFIG to be able to connect to the cluster ??????path file????????
export KUBECONFIG=$PWD/k8s_cluster/kubeconfig/kubeconfig.eastus.json

#show cluster info to validate
echo "cluster nodes :"
kubectl get nodes

#build docker image for bitcoin_rate app
sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "/home/$USER/.docker" -R


#install ingress-nginx using helm
sudo chown "$USER":"$USER" /home/rima/.cache/helm/ -R
sudo chmod g+rwx /home/rima/.cache/helm/repository/ingress-nginx-index.yaml -R

echo "installing ingress-nginx using helm ..."
kubectl create namespace ingress-basic
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-basic --set controller.replicaCount=2 --set controller.nodeSelector."kubernetes\.io/os"=linux --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux

#create first service
cd ./bitcoin_app
echo "pushing service script to docker ..."
sudo docker build -t bitcoin_app -f Dockerfile .
sudo docker tag bitcoin_app rimakh/bitcoin_app:latest
sudo docker push rimakh/bitcoin_app:latest

echo "creating first service ..."
kubectl create -f ./bitcoin_app.yaml

#create second service
echo "creating second service ..."
kubectl create -f ../simple_app.yaml
#create ingress
echo "creating ingress ..."
kubectl create -f ../simple-ingress.yaml

