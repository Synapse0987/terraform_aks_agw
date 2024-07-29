# Guide to using terraform to deploying an Azure Kubernetes Service (AKS) fronted by an application gateway (AGW)
This project is to use terraform to deploy an Azure Kubernetes Service, application gateway, log analytics workspace and relevant resources as required. 
<br/> The AKS is fronted by an application gateway while the Kubernetes audit logs for the cluster is being sent into the Log Analytics Workspace.
<br/> To authenticate into the AKS cluster, entra ID is used instead of the traditional way of creating user certificates and keys.

## This guide runs on the following assumptions.
1. You are using Ubuntu OS. I am running Ubuntu 22.04.4 LTS
2. Azure cli is installed and used to get or add Azure related resources
3. Kubectl is installed. If not installed, kubectl can be installed using Azure cli using the following command
<br/>`az aks install-cli` 
4. Azure account used to log into the cli have permissions to create a service principal and assign roles
5. An Azure storage account is required to store state file for high availability

## Pre-requisites 
  1. This repository is cloned into your machine
  2. A service principal has been created with the contributor and role base access control administrator roles to the subscription
     If not created, run the following command to create one using Azure cli (make sure you are logged into Azure) 
     <br/>- `az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<subscription_id>`
     <br/>- `spID=$(az ad sp list --display-name <service_principal_name> --query "[].{spID:appId}" --output tsv)`
     <br/>- `az role assignment create --assignee $spID --role "Role Based Access Control Administrator" --scope "/subscriptions/<subscription_id>"`
  3. Credentials related to the service principal is exported as an environment variable. They can be added into the `~/.bashrc` file as a permenant environment variable 
      <br/>**DO NOT CHANGE THE FOLLOWING VARIABLE NAMES**
      <br/>`export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"`
      <br/>`export ARM_TENANT_ID="<azure_subscription_tenant_id>"`
      <br/>`export ARM_CLIENT_ID="<service_principal_appid>"`
      <br/>`export ARM_CLIENT_SECRET="<service_principal_password>"`
  4. An Azure storage account is configured as a backend to save the tf.state files. Hence, an additional environment variable would need to be exported for the storage acount key. It can be added to the `~/.bashrc` file as a permenant environment variable
      <br/>**DO NOT CHANGE THE FOLLOWING VARIABLE NAME**
      <br/>`export ARM_ACCESS_KEY="<storage_account_access_key>" `
<br/>
<br/>
To check for the environment variables, the following command can be ran.
<br/> `printenv | grep ARM` 

## Terraform guide
This portion will go into details the different parts of the terraform deployment. They can be found in `terraform_aks_agw/terraform`
<br/>

### <u>Terraform providers</u>
Terraform providers act as the bridge between Terraform and the APIs of the services it manages.
AzureRM is used for this project and configurations can be found from the providers.tf file in the terraform root folder. Terraform will look for the environment variables as exported in the pre-requisites and initialize. 
<br/>This is more secure as the service principal credentials and storage account key will only exist within the machine running this terraform configuration and not be exposed to the internet. 

### <u>Terraform main</u> 
Terraform main acts as the core configuration file where the main infrastructure resources are defined and contains the essential resources and settings needed to create and manage infrastructure.
<br/> In this repository, the `main.tf` file contains 2 modules, `az_rg_vn` and `az_aks`. Details for each module can be found below.
- `az_rg_vn` : Creates all the resources (such as resource group, virtual network, subnets, log analytics workspace) required for the deployment of the AKS and AGW
- `az_aks` : Creates the AKS cluster and AGW with configurations (such as disabling local account, adding a role assignment for the application gateway and setting diagnostic settings etc)

`az_rg_vn` is configured in such a way that they are independant from each other and can be reused for other uses and the output from that module forms a foundation for `az_aks` to build on.
<br/> Configuration for each individual module can be found under the `modules` directory. 
<br/> 

### <u>Terraform variables</u> 

Terraform variables enables the terraform main configuration to accept different inputs, making it more dynamic and reusable. For the `variables.tf` file in the terraform root directory, it contains variables used globally by both modules like the location and admin group. For specific variable used by each module, they can be found under each individual module files under the `modules` directory. 
<br/>A `tfvars` file can be created to give custom values to the variables. This provides reusability of the modules by configuring the `tfvars` file.

### <u>Terraform user guide</u>

1. Change directory into the terraform root directory and run the command
<br/>`terraform init`
<br/>Terraform will initialize the providers automatically. Upon initialization, a `.terraform` directory with the providers defined will be created in the terraform root directory.

2. Create a `<name-of-your-tfvars-file>.tfvars` file for the following
- `location` : for the region used for the deployment
- `aks_admin_group` : Object Id of the group created for aks admin role in Entra ID

3. To get the deployment information, use the command
<br/> `terraform plan -var-file=<your-tfvars-file-name>`

4. Once the previous command shows no error, use the following command to deploy the resources
<br/>`terraform apply -var-file=<your-tfvars-file-name>`
<br/> **Some common errors may include the lack of a certain resource for the AKS node. This can be resolved by changing the instance name in the `modules/aks/main.tf` under the `default_node_pool` variable to another instance name.

## Kubernetes guide

This portion will go into details the different parts of the kubernetes deployment. They can be found in `terraform_aks_agw/kubernetes`.

### assignment-deployment.yaml file
This yaml file deploys a namespace called *tf-assignment*, a deployment with 1 nginx replica, a service to open port 80 of nginx and an ingress to configure Azure application gateway all under the same namespace.

### cluster-roles.yaml
This yaml deploys a cluster role to list and get namespaces. A user without this RBAC will be forbidden from getting and listing namespaces. 
<br/>A cluster role binding deployment to bind the cluster role for a group or user created in Entra ID. Change the kind field to group or user and use the respective object id for the name field as needed to bind the role to the user.

### namespace-admin-role.yaml
This yaml deploys a role to give all permissions for the *tf-assignment* namespace.
<br/>A role binding deployment to bind the role to a group or user created in Entra ID. Change the kind field to group or user and use the respective object id for the name field as needed to bind the role to the user.

### Kubernetes user guide
1. After AKS is deployed, it can be accessed using the following command while logged in using an account from Entra ID
<br/>`az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>`
<br/>**If unable to run any kubectl commands due to permission errors, add the user into the admin group configured in the terraform configuration for it to have admin permissions in the cluster

2. Files can be deployed using the following command in the kubernetes root folder
<br/>`kubectl apply -f <kubernetes-file-name.yaml>`
<br/>**Run the assignment-deployment.yaml file to create the namespace first