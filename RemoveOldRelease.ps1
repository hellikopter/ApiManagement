<#
.SYNOPSIS
Deletes all APIs for a particular relase.

.DESCRIPTION
Deletes all APIs for a particular relase.

.PARAMETER APIResourceGroupName
Name of the Resource Group where the API Management is.

.PARAMETER APIManagementName
Name of the API Management.

.NOTES
This script is for use as a part of deployment in VSTS only.
#>

Param(
    [Parameter(Mandatory=$true)] [string] $APIResourceGroupName,
    [Parameter(Mandatory=$true)] [string] $APIManagementName,
	[Parameter(Mandatory=$true)] [string] $APIPrefix
)
$ErrorActionPreference = "Stop"

function Log([Parameter(Mandatory=$true)][string]$LogText){
    Write-Host ("{0} - {1}" -f (Get-Date -Format "HH:mm:ss.fff"), $LogText)
}

Log "Get API Management context"
$management=New-AzureRmApiManagementContext -ResourceGroupName $APIResourceGroupName -ServiceName $APIManagementName

Log "Remove $APIPrefix"

$products=Get-AzureRmApiManagementProduct -Context $management | Where-Object Title -Match "$APIPrefix -" 
foreach ($product in $products){
	Log $product.Title
	$subscription=Get-AzureRmApiManagementSubscription -Context $management -ProductId $product.ProductId
	Remove-AzureRmApiManagementSubscription -Context $management -SubscriptionId $subscription.SubscriptionId
	Remove-AzureRmApiManagementProduct -Context $management -ProductId $product.ProductId
}

$apis=Get-AzureRmApiManagementApi -Context $management | Where-Object Name -Match "$APIPrefix -" 
foreach ($api in $apis){
	Log $api.Name
	Remove-AzureRmApiManagementApi -Context $management -ApiId $api.ApiId
}

Log "Job well done!"