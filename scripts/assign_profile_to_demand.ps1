###########################################################
# FILE		: assign_profile_to_demand
# AUTHOR  	: A. Cassidy 
# DATE    	: 2015-03-18 
# EDIT    	: 2015-03-22
# COMMENT 	: 1. SETUP
#             2. FUNCTION
#           
# VERSION : 1.2
###########################################################
# 
# CHANGELOG
# Version 1.1: 2015-03-20 
# - Added better Error Handling and Reporting.
#
# Version 1.2: 2015-03-22
# - Fixed settings file fault



# ERROR REPORTING ALL
Set-StrictMode -Version latest



###########################################################
#
#region SETUP
#
###########################################################
#
#----------------------------------------------------------
#STATIC VARIABLES
#----------------------------------------------------------
$settings_file	= "G:\github_clone\tourmalet\settings\assign_profile_to_demand_settings.ini"
$TIMES = Get-Date -format yyyy-MM-dd_hh-mm-ss
$VOLUMETRIC = "Volumetric"
$BASE_VOLUMETRIC = "Base Volumetric"

#----------------------------------------------------------
# LOAD SETTINGS FILE
#----------------------------------------------------------
Try
{
	# FileNotFound Exception will not cause PShell failure so explicitly state
    $ErrorActionPreference = "Stop"
    # Get settings content - there is some cleverness here to cope with ini format ( [ModelName] etc..)
    Get-Content $settings_file | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
    # Does data exist?
    if ($?){ } # continue
    else { throw $error[0].exception}
}
Catch
{
	Write-Host "[ERROR]`t`tSettings file could not be loaded. Script will exit"
	Write-Host "[ERROR]`t`t$($settings_file)"
	#Exit 1
}

#----------------------------------------------------------
# LOAD SCRIPT VARIABLES FROM SETTINGS
#----------------------------------------------------------
# Initiate the log for recording script
$SCRIPT_LOG = $($h.Get_Item("script_log") + "_$TIMES.log")
# Get N1, N2 etc... info
$REGIONS = Get-Content $h.Get_Item("regions")
# Banned flows
$BANNED_FLOWS = Get-Content $h.Get_Item("banned_flows")

#----------------------------------------------------------
# BEGIN LOG
#----------------------------------------------------------
"[SETUP]`t`tProcessing started (on " + $TIMES + "): " | Out-File $SCRIPT_LOG -append
"[SETUP]`t`tA log of script has been created: $($SCRIPT_LOG)" | Out-File $SCRIPT_LOG -append
"[SETUP]`t`t------------------------------------------------" | Out-File $SCRIPT_LOG -append
#endregion







###########################################################
#
#region FUNCTION
#
###########################################################
#
#----------------------------------------------------------
# BEGIN ITERATIONS
#----------------------------------------------------------
$region_count = $REGIONS.length
# Loop through regions
for ($j = 0; $j -lt $region_count; $j++)
{
	write-progress -Activity 'Assign Demand' -status "Processsing Regions" -percentcomplete ($j/8*100) -id 0 -currentoperation $REGIONS[$j]
	"[$($REGIONS[$j])]`t`tBegin models in $($REGIONS[$j])" | Out-File $SCRIPT_LOG -Append

	# Tell log about profile info and changes
	$PROFILE_INFO = $h.Get_Item("profile_info") + $REGIONS[$j] + "_profile_info.log"
	$CHANGE_LOG = $h.Get_Item("change_log") + $REGIONS[$j] + "_change_log.log"
	"[OUTPUT]`t`tProfile information saved: $($PROFILE_INFO)" | Out-File $SCRIPT_LOG -Append
	"[OUTPUT]`t`tChange log: $($CHANGE_LOG)" | Out-File $SCRIPT_LOG -Append
	
    #----------------------------------------------------------
    # Get models from list
    #----------------------------------------------------------
	$list_of_models_file = $h.Get_Item("$($REGIONS[$j])_flows")
	"[$($REGIONS[$j])]`t`tModel list taken from $($list_of_models_file)" | Out-File $SCRIPT_LOG -Append
	
	try
	{
		# FileNotFound Exception will not cause PShell failure so explicitly state
    	$ErrorActionPreference = "Stop"
		$list_of_models_data = Get-Content $list_of_models_file
		if ($?){ } # continue
    	else { throw $error[0].exception}
		"[$($REGIONS[$j])]`t`tModel list successfully loaded" | Out-File $SCRIPT_LOG -Append
	}
	catch
	{
		"[ERROR]`t`tList contains no models: $($list_of_models_file)" | Out-File $SCRIPT_LOG -Append
		break;
	}
	
	$model_count = $list_of_models_data.length
	"[$($REGIONS[$j])]`t`tThere are $($model_count) models to process" | Out-File $SCRIPT_LOG -Append
	

    # Repeat for every model in list  
	for($k=0;$k -lt $model_count; $k++)
	{
		write-progress -Activity 'Sort Profiles' -status "Progress:" -percentcomplete ($k/$model_count*100) -id 1 -currentoperation $list_of_models_data[$k]		
		"[$($REGIONS[$j])]`t[$($k)]`tProcessing $($list_of_models_data[$k])" | Out-File $SCRIPT_LOG -Append
		
        #----------------------------------------------------------
        # Get exchange files with flows etc...
        #----------------------------------------------------------  
		# 
		$flow_category_path = $h.Get_Item("flow_extracts") + $REGIONS[$j] + "_all_nodes\" + $list_of_models_data[$k] + "_flow_categories.csv"
		$all_nodes_path = $h.Get_Item("flow_extracts") + $REGIONS[$j] + "_all_nodes\" + $list_of_models_data[$k] + "_all_nodes.csv"
		
		# ... now test them ... 
		if (Test-Path $flow_category_path){ }
		else{ "[ERROR]`t[$($k)]`tFlow category file not loaded: $($flow_category_path)" | Out-File $SCRIPT_LOG -Append; continue}
		if (Test-Path $all_nodes_path){ }
		else{ "[ERROR]`t[$($k)]`tNodes file not loaded: $($all_nodes_path)" | Out-File $SCRIPT_LOG -Append; continue}
		
		# array to hold all the different flows (D1, C1, C2...)
		$flow_category = @()
		try 
		{
			$flow_category_data = Import-CSV $flow_category_path 
			"[$($REGIONS[$j])]`t[$($k)]`tImport Flow Category" | Out-File $SCRIPT_LOG -Append
		}
		catch 
		{
			"[ERROR]`t[$($k)]`tUnsuccessful attempt to open flow cats for $($flow_category_path)" | Out-File $SCRIPT_LOG -Append
			continue
		}
		

		# array to hold all node information
		$node_data = @()		
		try 
		{
			$node_data = Import-CSV $all_nodes_path
			"[$($REGIONS[$j])]`t[$($k)]`tImport all nodes" | Out-File $SCRIPT_LOG -Append
		}
		catch 
		{			
			"[ERROR]`t[$($k)]`tUnsuccessful attempt to open all nodes for $($all_nodes_path)" | Out-File $SCRIPT_LOG -Append
			continue
		}
		
        #----------------------------------------------------------
        # Turn off banned flows
        #---------------------------------------------------------- 
		# 
		foreach ($fc in $flow_category_data)
		{
			if ($banned_flows -contains $fc.NAME)
			{
				$fc.CategoryActive = 0
				$model_info += "$($list_of_models_data[$k]),$($fc.NAME),"
				"[$($REGIONS[$j])]`t[$($k)]`tTurn off $($fc.NAME)" | Out-File $PROFILE_INFO -Append
			}
			else
			{
				if ($fc.FlowCategoryType -eq "Volumetric" -and $fc.NAME -ne "Base Volumetric")
				{
					$flow_category += $fc.NAME
					$model_info += "$($list_of_models_data[$k]),,$($fc.NAME)"
					"[$($REGIONS[$j])]`t[$($k)]`tKeep $($fc.NAME)" | Out-File $PROFILE_INFO -Append
				}
			}
		}
		
		
        #----------------------------------------------------------
        # Give every demand tag a profile name
        #---------------------------------------------------------- 
		# 
		$flow_category_count = $flow_category.count		
		for ($i = 0; $i -lt $flow_category_count; $i++)
		{
			$NodeFlowByCategory = "NodeFlowByCategory($($flow_category[$i]))"
			$NodeFlowProfileNameByCategory = "NodeFlowProfileNameByCategory($($flow_category[$i]))"
			
			try 
			{
				$node_data | Where-Object { $_.$NodeFlowByCategory -ne ""} | Foreach-object { $_.$NodeFlowProfileNameByCategory = "$($flow_category[$i]) PROFILE"}
			}
			catch
			{
				"[ERROR]`t[$($k)]`tUnsuccessful attempt to modify flow category $($flow_category[$i]) " | Out-File $SCRIPT_LOG -Append
			}
		}
		

        #----------------------------------------------------------
        # Export to exchange file
        #---------------------------------------------------------- 
		# 		
		"[$($REGIONS[$j])]`t[$($k)]`tExport to file" | Out-File $SCRIPT_LOG -Append
			
		try
		{
			$flow_category_data | Export-CSV $flow_category_path -NoTypeInformation
			"[$($REGIONS[$j])]`t[$($k)]`tWrite to flow cats successful $($flow_category_path)" | Out-File $SCRIPT_LOG -Append
		}
		catch
		{
			"[ERROR]`t[$($k)]`tUnsuccessful attempt to write flow cats to $($flow_category_path)" | Out-File $SCRIPT_LOG -Append
		}
		
		try
		{
			$node_data | Export-CSV $all_nodes_path -NoTypeInformation
			"[$($REGIONS[$j]) - $($k)]`tWrite to node data successful $($all_nodes_path)" | Out-File $SCRIPT_LOG -Append
		}
		catch
		{
			"[ERROR]`t[$($k)]`tUnsuccessful attempt to write all node data to $($all_nodes_path)" | Out-File $SCRIPT_LOG -Append
		}
		
		try
		{
			$model_info | Out-File $CHANGE_LOG
		}
		catch
		{
			"[ERROR]`t[$($k)]`tCould not write model info to file" | Out-File $SCRIPT_LOG -Append
		}
	}
	
}#endregion

"[SCRIPT]`tScript ended." | Out-File $SCRIPT_LOG -Append	