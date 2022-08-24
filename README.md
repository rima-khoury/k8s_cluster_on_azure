# Deploy k8s Cluster on Azure
Create k8s cluster using azure CLI and aks-engine
In this example we are going to create a kubernetes cluster on top of azure using azure cli and aks-engine ( not predefined aks ).\
In order to successfully run this example you need to have a linux host machine with external access and open TCP port 22 (SSH) to be able to connect remotely. I am using ubuntu 18.04. We will referr to this host as 'managerhost' in this example.

## Preparations
Connect to your managerhost using SSH or any other form that works and follow the next steps.\
1. Start docker service
    ``` 
    sudo apt-get update 
    sudo apt-get install docker.io 
    sudo systemctl enable docker 
    sudo systemctl start docker 
    ```
2. Download and install azure CLI\
    For this example I followed [Install the Azure CLI on Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt) guide from Microsoft documentation.\
    Verify with following command
    ```
    az version
    ```

3. Downlaod and install aks-engine\
    For this example I followed [Install the AKS engine on Linux in Azure Stack Hub](https://docs.microsoft.com/en-us/azure-stack/user/azure-stack-kubernetes-aks-engine-deploy-linux?view=azs-2206) guide from Microsoft documentation. For this example I am using version 0.70.0\
    Verify with following command
    ```
    aks-engine version
    ```

4. Download and install kubectl\
    Follow the [install kubectl on linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) from the kubernetes documentations.\
    Verify with following command
    ```
    kubectl version --client
    ```

After you have successfully installed previous packages login to your azure portal with "az login", follow instruction and connect to you azure portal. after you login you should be able to see your account details with "az account show". The next step would be to create a service principal and save the client-ID and client-secret.\
Download files to your working directory and proceed to deployment. In the api model make sure to update the service principal client ID and secret, and the ssh key to your linux host.

## Run Deployment
    navigate to your working directory where you downloaded the project and run myscript.sh
    
    ```
    source myscript.sh
    ```
    If you get an error such as : command not found or : invalid option, it might be because github aggregates special characters to *.sh files. in order to overcome this, copy the raw content of the file to your hostmanager and then try to run it again.

    
