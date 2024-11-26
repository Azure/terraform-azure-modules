$clientId = Get-AutomationVariable -Name 'ARM_CLIENT_ID'
$subscriptionId = Get-AutomationVariable -Name 'ARM_SUBSCRIPTION_ID'

Disable-AzContextAutosave -Scope Process
$AzureContext = (Connect-AzAccount -Identity -AccountId $clientId).context
$AzureContext = Set-AzContext -Subscription $subscriptionId -DefaultProfile $AzureContext

$connectedSubscriptionId = (Get-AzContext).Subscription.id

Write-Output "Subscription Id: $connectedSubscriptionId"

$reaperDelay = Get-AutomationVariable -Name 'REAPER_DELAY_HOURS'
$currentDate = Get-Date
$reapDate = ($currentDate).AddHours(0 - $reaperDelay)

Write-Output "Current time stamp: $currentDate"
Write-Output "Reap time stamp: $reapDate"

$resourceGroups = Get-AzResourceGroup
$resourceGraphQuery = @"
resourcecontainerchanges `
    | where subscriptionId == "$subscriptionId"
    | where properties.targetResourceType == "microsoft.resources/subscriptions/resourcegroups"
    | where properties.changeType == "Create"
    | where todatetime(properties.changeAttributes.timestamp) > now(-7d)
    | extend changeTime = todatetime(properties.changeAttributes.timestamp), resourceGroupName = split(properties.targetResourceId, "/")[4]
    | order by changeTime desc
    | project changeTime, resourceGroupName
"@
$resourceGroupQueryResults = Search-AzGraph -Query $resourceGraphQuery

$resourceGroupDates = @{}

foreach($resourceGroupQueryResult in $resourceGroupQueryResults) {
    if($resourceGroupDates.ContainsKey($resourceGroupQueryResult.resourceGroupName)) {
        continue
    }
    $resourceGroupDates.Add($resourceGroupQueryResult.resourceGroupName, $resourceGroupQueryResult.changeTime)
}

foreach($resourceGroup in $resourceGroups) {
    $resourceGroupName = $resourceGroup.ResourceGroupName
    Write-Output "Checking resource group: $resourceGroupName"
    if($resourceGroupName -eq "NetworkWatcherRG") {
        Write-Output "Skipping $resourceGroupName"
        continue
    }

    if(!$resourceGroupDates.ContainsKey($resourceGroupName)) {
        Write-Output "Can't find the created date for $resourceGroupName, skipping this time as must be new..."
        continue
    }

    $createdDate = $resourceGroupDates[$resourceGroupName]
    if($reapDate -gt $createdDate) {
        Write-Output "Reaper time has passed, deleting $resourceGroupName"
        Remove-AzResourceGroup -Name $resourceGroupName -Force
    } else {
        Write-Output "Reaper time has not passed yet for $resourceGroupName, it is $createdDate"
    }
}
