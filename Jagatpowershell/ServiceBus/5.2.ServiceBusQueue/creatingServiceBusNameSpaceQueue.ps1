
[CmdletBinding(PositionalBinding=$True)]
Param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[a-z0-9]*$")]
    [String]$QueueName,                                      # required    needs to be alphanumeric    
    [Int]$AutoDeleteOnIdle = -1,                             # optional    default to -1
    [Int]$DefaultMessageTimeToLive = -1,                     # optional    default to -1
    [Int]$DuplicateDetectionHistoryTimeWindow = 10,          # optional    default to 10
    [Bool]$EnableBatchedOperations = $True,                  # optional    default to true
    [Bool]$EnableDeadLetteringOnMessageExpiration = $False,  # optional    default to false
    [Bool]$EnableExpress = $False,                           # optional    default to false
    [Bool]$EnablePartitioning = $False,                      # optional    default to false
    [String]$ForwardDeadLetteredMessagesTo = $Null,          # optional    default to null
    [String]$ForwardTo = $Null,                              # optional    default to null
    [Bool]$IsAnonymousAccessible = $False,                   # optional    default to false
    [Int]$LockDuration = 30,                                 # optional    default to 30
    [Int]$MaxDeliveryCount = 10,                             # optional    default to 10
    [Int]$MaxSizeInMegabytes = 1024,                         # optional    default to 1024
    [Bool]$RequiresDuplicateDetection = $False,              # optional    default to false
    [Bool]$RequiresSession = $False,                         # optional    default to false
    [Bool]$SupportOrdering = $True,                          # optional    default to true
    [String]$UserMetadata = $Null,                           # optional    default to null
    [Parameter(Mandatory = $true)]
    [ValidatePattern("^[a-z0-9]*$")]
    [String]$Namespace,                                      # required    needs to be alphanumeric
    [Bool]$CreateACSNamespace = $False,                      # optional    default to $false
    [String]$Location = "East US"                            # optional    default to "East US"
    )


$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"


Write-Output "Adding the [Microsoft.ServiceBus.dll] assembly to the script..."
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Team Foundation Server\15.0\Microsoft.ServiceBus.dll"
Write-Output "The [Microsoft.ServiceBus.dll] assembly has been successfully added to the script."


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
Write-Host "NamespaceManager object for the namespace has been successfully created."


if ($NamespaceManager.QueueExists($QueueName))
{
    Write-Output "The queue already exists in the namespace." 
}
else
{
    Write-Output "Creating the [$QueueName] queue in the [$Namespace] namespace..."
    $QueueDescription = New-Object -TypeName Microsoft.ServiceBus.Messaging.QueueDescription -ArgumentList $QueueName
    if ($AutoDeleteOnIdle -ge 5)
    {
        $QueueDescription.AutoDeleteOnIdle = [System.TimeSpan]::FromMinutes($AutoDeleteOnIdle)
    }
    if ($DefaultMessageTimeToLive -gt 0)
    {
        $QueueDescription.DefaultMessageTimeToLive = [System.TimeSpan]::FromMinutes($DefaultMessageTimeToLive)
    }
    if ($DuplicateDetectionHistoryTimeWindow -gt 0)
    {
        $QueueDescription.DuplicateDetectionHistoryTimeWindow = [System.TimeSpan]::FromMinutes($DuplicateDetectionHistoryTimeWindow)
    }
    $QueueDescription.EnableBatchedOperations = $EnableBatchedOperations
    $QueueDescription.EnableDeadLetteringOnMessageExpiration = $EnableDeadLetteringOnMessageExpiration
    $QueueDescription.EnableExpress = $EnableExpress
    $QueueDescription.EnablePartitioning = $EnablePartitioning
    $QueueDescription.ForwardDeadLetteredMessagesTo = $ForwardDeadLetteredMessagesTo
    $QueueDescription.ForwardTo = $ForwardTo
    $QueueDescription.IsAnonymousAccessible = $IsAnonymousAccessible
    if ($LockDuration -gt 0)
    {
        $QueueDescription.LockDuration = [System.TimeSpan]::FromSeconds($LockDuration)
    }
    $QueueDescription.MaxDeliveryCount = $MaxDeliveryCount
    $QueueDescription.MaxSizeInMegabytes = $MaxSizeInMegabytes
    $QueueDescription.RequiresDuplicateDetection = $RequiresDuplicateDetection
    $QueueDescription.RequiresSession = $RequiresSession
    if ($EnablePartitioning)
    {
        $QueueDescription.SupportOrdering = $False
    }
    else
    {
        $QueueDescription.SupportOrdering = $SupportOrdering
    }
    $QueueDescription.UserMetadata = $UserMetadata
    $NamespaceManager.CreateQueue($QueueDescription);
    Write-Host "The [$QueueName] queue in the [$Namespace] namespace has been successfully created."
}


$finishTime = Get-Date


$TotalTime = ($finishTime - $startTime).TotalSeconds
Write-Output "The script completed in $TotalTime seconds."