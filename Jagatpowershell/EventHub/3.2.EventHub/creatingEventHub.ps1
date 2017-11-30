
[CmdletBinding(PositionalBinding=$True)]
Param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[a-z0-9]*$")]
    [String]$EventHubName,                               # required    needs to be alphanumeric    
    [Int]$PartitionCount = 16,                           # optional    default to 16
    [Int]$MessageRetentionInDays = 7,                    # optional    default to 7
    [String]$UserMetadata = $null,                       # optional    default to $null
    [String]$ConsumerGroupUserMetadata = $null,          # optional    default to $null
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[a-z0-9]*$")]
    [String]$Namespace,                                  # required    needs to be alphanumeric
    [Bool]$CreateACSNamespace = $False,                  # optional    default to $false
    [String]$Location = "East US"                        # optional    default to "East US"
    )


$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


Write-Output "The process of adding the Microsoft.ServiceBus.dll will start now..."
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Team Foundation Server\14.0\Microsoft.ServiceBus.dll"
Write-Output "The Microsoft.ServiceBus.dll file successfully added to the script..."


$startTime = Get-Date


$CurrentNamespace = Get-AzureSBNamespace -Name $Namespace


if ($CurrentNamespace)
{
    Write-Output "The namespace [$Namespace] already exists in the [$($CurrentNamespace.Region)] region." 
	
}
else
{
    Write-Host "The [$Namespace] namespace does not exist."
    Write-Output "Creating the [$Namespace] namespace in the [$Location] region..."
    New-AzureSBNamespace -Name $Namespace -Location $Location -CreateACSNamespace $CreateACSNamespace -NamespaceType Messaging
    $CurrentNamespace = Get-AzureSBNamespace -Name $Namespace
    Write-Host "The [$Namespace] namespace in the [$Location] region has been successfully created."
}


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