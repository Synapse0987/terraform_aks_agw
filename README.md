# terraform_aks_agw
Terraform for deploying AKS, AGW and create resources that is required

Pre-requisites
  1. A service principal has been created to authenticate against Azure
     If not created, run the following command to create one using Azure cli (make sure you are logged into Azure)
     `az ad sp create-for-rbac --name <service_principal_name> --role Contributor --scopes /subscriptions/<subscription_id>`
  2. Credentials related to the service principal is exported as an environment variable. It can be added into the `~/.bashrc` file
      - `export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"`
      - `export ARM_TENANT_ID="<azure_subscription_tenant_id>"`
      - `export ARM_CLIENT_ID="<service_principal_appid>"`
      - `export ARM_CLIENT_SECRET="<service_principal_password>"`

Prior to initiating terraform, e
