[CmdletBinding(PositionalBinding=$True)]
Param(
   # [Parameter(Mandatory = $true)]
  #  [ValidatePattern("^[a-z0-9]*$")]
 #$*[String]$EventHubName,                               # required    needs to be alphanumeric  
  #  [String]$ContainerName,                              # required    needs to be alphanumeric  	
  #  [Int]$PartitionCount = 16,                           # optional    default to 16
   # [Int]$MessageRetentionInDays = 7,                    # optional    default to 7
   # [String]$UserMetadata = $null,                       # optional    default to $null
   # [String]$ConsumerGroupUserMetadata = $null,          # optional    default to $null
   # [Parameter(Mandatory = $true)]
   # [ValidatePattern("^[a-z0-9]*$")]
 #$*[String]$Namespace,                                  # required    needs to be alphanumeric
    [String]$subscriptionId="e2186114-ebc1-4579-87b0-d455b33cd6cf",
    [String]$ResourceGroup,                               # required    needs to be alphanumeric
	[String]$StorageAccount,                             # required    needs to be alphanumeric
   # [Bool]$CreateACSNamespace = $False,                  # optional    default to $false
    [String]$Location = "East US"                        # optional    default to "East US"
	
    )


$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


Write-Output "The process of adding the Microsoft.ServiceBus.dll will start now..."
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Team Foundation Server\14.0\Microsoft.ServiceBus.dll"
Write-Output "The Microsoft.ServiceBus.dll file successfully added to the script..."

Write-Host "Logging in...";
Login-AzureRmAccount;


Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;


#$* $CurrentNamespace = Get-AzureSBNamespace -Name $Namespace
    $ResourceGroupone = New-AzureRmResourceGroup -Name $ResourceGroup -Location $location
    $StorageAccountone = New-AzureStorageAccount –StorageAccountName $StorageAccountone -Location $location
    $CurrentResourceGroup = Get-AzureRmResourceGroup $ResourceGroupone
    $CurrentStorageAccount = Get-AzureStorageAccount $StorageAccountone

If ($CurrentResourceGroup)	
    {
        Write-Output "The Resource Group [$CurrentResourceGroup] already exists in the [$($CurrentResourceGroup.Region)] region."
      	if ($CurrentStorageAccount){
           Write-Output "The Storage Account [$CurrentStorageAccount] already exists in the [$($CurrentStorageAccount.Region)] region."
		}   
	    else
           {
				Write-Host "The [$CurrentStorageAccount] Storage Account does not exist."
				Write-Output "Creating the [$CurrentStorageAccount] Storage Account in the [$Location] region"
				$StorageAccounttwo = New-AzureStorageAccount –StorageAccountName $StorageAccountone -Location $location
				$CurrentStorageAccount = Get-AzureStorageAccount $StorageAccounttwo
				Write-Host "The [$StorageAccount] Storage Account in the [$Location] region has been successfully created."
			}
    }			
else
    {
	   Write-Host "The [$CurrentResourceGroup] Resource Group does not exist."
       Write-Output "Creating the [$CurrentResourceGroup] Resource Group in the [$Location] region"
	   New-AzureRmResourceGroup -Name $ResourceGroupone -Location $Location
	   $CurrentResourceGroup = Get-AzureRmResourceGroup $ResourceGroupone
	   if ($CurrentStorageAccount){
           Write-Output "The Storage Account [$CurrentStorageAccount] already exists in the [$($CurrentStorageAccount.Region)] region." 
	    }	   
	   else
	       {
				Write-Host "The [$CurrentStorageAccount] Storage Account does not exist."
				Write-Output "Creating the [$CurrentStorageAccount] Storage Account in the [$Location] region"
				New-AzureStorageAccount –StorageAccountName $StorageAccountone -Location $location
				$CurrentStorageAccount = Get-AzureStorageAccount $StorageAccountone
				Write-Host "The [$StorageAccount] Storage Account in the [$Location] region has been successfully created."
	       }
	
	
	}

	<#
if ($CurrentStorageAccount)
{
    Write-Output "The Storage Account [$CurrentStorageAccount] already exists in the [$($CurrentStorageAccount.Region)] region." 
	
}
else
{
    Write-Host "The [$CurrentStorageAccount] Storage Account does not exist."
    Write-Output "Creating the [$CurrentStorageAccount] Storage Account in the [$Location] region"
	New-AzureStorageAccount -Name $StorageAccount -Location $location
# $* New-AzureSBNamespace -Name $Namespace -Location $Location -CreateACSNamespace $CreateACSNamespace -NamespaceType Messaging
# $* $CurrentNamespace = Get-AzureSBNamespace -Name $Namespace
	$CurrentStorageAccount = Get-AzureStorageAccount -Name $StorageAccount
    Write-Host "The [$StorageAccount] Storage Account in the [$Location] region has been successfully created."
}

<#

Write-Host "Creating a NamespaceManager object for the [$Namespace] namespace..."
$NamespaceManager = [Microsoft.ServiceBus.NamespaceManager]::CreateFromConnectionString($CurrentNamespace.ConnectionString);
Write-Host "NamespaceManager object for the [$Namespace] namespace has been successfully created."


if ($NamespaceManager.EventHubExists($EventHubName))
{
    Write-Output "The [$EventHubName] event hub already exists in the [$Namespace] namespace." 
}
else
{
    Write-Output "Creating the [$EventHubName] event hub in the [$Namespace] namespace: PartitionCount=[$PartitionCount] MessageRetentionInDays=[$MessageRetentionInDays]..."
    $EventHubDescription = New-Object -TypeName Microsoft.ServiceBus.Messaging.EventHubDescription -ArgumentList $EventHubName
    $EventHubDescription.PartitionCount = $PartitionCount
    $EventHubDescription.MessageRetentionInDays = $MessageRetentionInDays
    $EventHubDescription.UserMetadata = $UserMetadata
    $NamespaceManager.CreateEventHub($EventHubDescription);
    Write-Host "The [$EventHubName] event hub in the [$Namespace] namespace has been successfully created."
}

$finishTime = Get-Date

$TotalTime = ($finishTime - $startTime).TotalSeconds
Write-Output "The script completed in $TotalTime seconds."

#>