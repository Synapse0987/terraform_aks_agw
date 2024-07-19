# Guide to using terraform to deploying an Azure Kubernetes Service fronted by an application gateway
This project is to use terraform to deploy an Azure Kubernetes Service, application gateway, log analytics workspace and relevant resources as required. 
<br/> The AKS is fronted by an application gateway while the Kubernetes audit logs for the cluster is being sent into the Log Analytics Workspace.
<br/> To authenticate into the AKS cluster, entra ID is used instead of the traditional way of creating user certificates and keys.

Pre-requisites
  1. A service principal has been created to authenticate against Azure
     If not created, run the following command to create one using Azure cli (make sure you are logged into Azure)
     `az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<subscription_id>`
  2. Credentials related to the service principal is exported as an environment variable. It can be added into the `~/.bashrc` file
      <br/>`export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"`
      <br/>`export ARM_TENANT_ID="<azure_subscription_tenant_id>"`
      <br/>`export ARM_CLIENT_ID="<service_principal_appid>"`
      <br/>`export ARM_CLIENT_SECRET="<service_principal_password>"`
  3. This terraform assignment uses Azure storage account as a backend to save the tf.state files. An additional environment variable would need to be exported for the storage acount key. Similar to 2, it can be added to the `~/.bashrc` file
      <br/>`export ARM_ACCESS_KEY="<storage_account_access_key>" `
