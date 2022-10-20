Connect-AzAccount

$resourceGroup = "AKS"
$location = "west europe"
$storage_name = "tfstate019"
New-AzResourceGroup -Name $resourceGroup -Location $location

New-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storage_name -Location $location  -SkuName Standard_LRS -Kind StorageV2

# Create a context object using Azure AD credentials
$ctx = New-AzStorageContext -StorageAccountName $storage_name -UseConnectedAccount

# Create variables
$containerName  = "tfstate"

# Approach 1: Create a container
New-AzStorageContainer -Name $containerName -Context $ctx