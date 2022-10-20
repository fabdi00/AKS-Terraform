Deploys AKS and application gateway ingress controller

First, run the PS script file: "create_rg_storageAccount.ps1" to create a new resource group and storage account to hold our tfstate file

Run the command "terraform init" from within the directory "AKS_AGIC" | this initializes your providers 

Run the command "terraform plan" | outputs the resources that will be created in the console for you to review before deploying

finally run the command "terraform apply" | Creates the resources 