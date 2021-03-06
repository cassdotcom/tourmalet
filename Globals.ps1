﻿#--------------------------------------------
# Declare Global Variables and Functions here
#--------------------------------------------



function assign_profile_to_demand
{
	[CmdletBinding()]
	Param(
	# Refers to the actual flow category, eg: 'D1'
	[Parameter(Position=0, Mandatory=$true)]
	[System.String]
	$flow_category,
	# Refers to the name of the flow profile, eg: 'D1 PROFILE'
	[Parameter(Position=1, Mandatory=$false)]
	[System.String]
	$profile_name,
	# Array containing all node demand data
	[Parameter(Position=2, Mandatory=$true)]
	[System.Array]
	$all_nodes
	)
	
	$profile_count = $all_nodes.length	

	# $path = 'G:\tourmalet\ASP\files\643012_Broxburn_all_nodes.csv'
#
#	$model_node_data = Get-Content -Path $path | ForEach-Object {$_ -replace "\(", "_"} | ForEach-Object {$_ -replace "\)", "_"}
#	$model_node_data | Set-content $path
#
#	$all_nodes = Import-CSV $path
#	$D1_profiles = $all_nodes | where-object {$_.NodeFlowByCategory_D1_ -lt 0}

# 	Write-host "There are $($D1_profiles.Count) D1 profiles"

	$NodeFlowByCategory = "NodeFlowByCategory_$($flow_category)_"
	$NodeFlowProfileNameByCategory = "NodeFlowProfileNameByCategory_$($flow_category)_"
	
	$fixed_profiles = $all_nodes | where-object {$_.$NodeFlowByCategory -lt 0} | ForEach-Object {$_.NodeFlowProfileNameByCategory_D1_ -replace " ", "D1 PROFILE"}

$fixed_profiles | Set-content $path 

	}













#Sample function that provides the location of the script
function Get-ScriptDirectory
{ 
	if($hostinvocation -ne $null)
	{
		Split-Path $hostinvocation.MyCommand.path
	}
	else
	{
		Split-Path $script:MyInvocation.MyCommand.Path
	}
}

#Sample variable that provides the location of the script
[string]$ScriptDirectory = Get-ScriptDirectory


