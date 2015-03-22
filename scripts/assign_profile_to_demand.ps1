###########################################################
# FILE		: assign_profile_to_demand
# AUTHOR  	: A. Cassidy 
# DATE    	: 2015-03-18 
# EDIT    	: 
# COMMENT 	: 
#           
# VERSION : 1.1
###########################################################
# 
# CHANGELOG
# Version 1.2: 15-04-2014 - Changed 
# - Added better Error Handling and Reporting.
#   HomeDirectory and HomeDrive
# Version 1.3: 08-07-2014
# - Added functionality for ProxyAddresses
 
# ERROR REPORTING ALL
Set-StrictMode -Version latest


#----------------------------------------------------------
#region STATIC VARIABLES
#----------------------------------------------------------
$settings_file	= "G:\github_clone\tourmalet\settings\assign_profile_to_demand_settings.ini"
$TIMES = Get-Date -format yyyy-mm-dd_hh-mm-ss
$VOLUMETRIC = "Volumetric"
$BASE_VOLUMETRIC = "Base Volumetric"
#endregion





#----------------------------------------------------------
#region LOAD SETTINGS
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
	Write-Host "[ERROR]`t Settings file could not be loaded. Script will exit"
	Write-Host "[ERROR]`t $($settings_file)"
	Exit 1
}
#endregion




#----------------------------------------------------------
#region LOAD SCRIPT VARIABLES FROM SETTINGS
#----------------------------------------------------------
# Initiate the log for recording script
$SCRIPT_LOG = $($h.Get_Item("script_log") + "_$TIMES.log")
# Get N1, N2 etc... info
$REGIONS = $h.Get_Item("regions")
# Banned flows
$BANNED_FLOWS = $h.Get_Item("banned_flows")
#endregion


# Create a log of what is done
Start-Transcript -path $SCRIPT_LOG
"[SETUP]`t Processing started (on " + $date + "): " | Out-File $SCRIPT_LOG -append
"[SETUP]`t A log of script has been created: $($SCRIPT_LOG)" | Out-File $SCRIPT_LOG -append
"[SETUP]`t ------------------------------------------------" | Out-File $SCRIPT_LOG -append

$region_count = $REGIONS.length



# Loop through regions
for ($j = 0; $j -lt $region_count; $j++)
{
	write-progress -Activity 'Assign Demand' -status "Processsing Regions" -percentcomplete ($j/8*100) -id 0 -currentoperation $REGIONS[$j]
	"[$($REGIONS[$j])]`t Begin models in $($REGIONS[$j])" | Out-File $SCRIPT_LOG -Append

	# Tell log about profile info and changes
	$PROFILE_INFO = $h.Get_Item("profile_info") + $REGIONS[$j] + "_profile_info.log"
	$CHANGE_LOG = $h.Get_Item("change_log") + $REGIONS[$j] + "_change_log.log"
	"[OUTPUT]`t Profile information saved: $($PROFILE_INFO)" | Out-File $SCRIPT_LOG -Append
	"[OUTPUT]`t Change log: $($CHANGE_LOG)" | Out-File $SCRIPT_LOG -Append
	
	# Get models from list
	$list_of_models_file = $h.Get_Item("$($REGIONS[$j])_flows")
	"[$($REGIONS[$j])]`t Model list taken from $($list_of_models_file)" | Out-File $SCRIPT_LOG -Append
	
	try
	{
		# FileNotFound Exception will not cause PShell failure so explicitly state
    	$ErrorActionPreference = "Stop"
		$list_of_models_data = Get-Content $list_of_models_file
		if ($?){ } # continue
    	else { throw $error[0].exception}
		"[$($REGIONS[$j])]`t Model list successfully loaded" | Out-File $SCRIPT_LOG -Append
	}
	catch
	{
		"[ERROR]`t List contains no models: $($list_of_models_file)" | Out-File $SCRIPT_LOG -Append
		break;
	}
	
	$model_count = $list_of_models_data.length
	"[$($REGIONS[$j])]`t There are $($model_count) models to process" | Out-File $SCRIPT_LOG -Append
	
	for($k=0;$k -lt $model_count; $k++)
	{
		write-progress -Activity 'Sort Profiles' -status "Progress:" -percentcomplete ($k/$model_count*100) -id 1 -currentoperation $list_of_models_data[$k]		
		"[$($REGIONS[$j]) - $($k)]`t Processing $($list_of_models_data[$k])" | Out-File $SCRIPT_LOG -Append
		
		# Get exchange files with flows etc...
		$flow_category_path = $h.Get_Item("flow_extracts") + $list_of_models_data[$k] + "_flow_categories.csv"
		$all_nodes_path = $h.Get_Item("flow_extracts") + $list_of_models_data[$k] + "_all_nodes.csv"
		
		# ... now test them ... 
		if (Test-Path $flow_category_path){ }
		else{ "[ERROR - $($k)]`t Flow category file not loaded: $($flow_category_path)" | Out-File $SCRIPT_LOG -Append; continue}
		if (Test-Path $all_nodes_path){ }
		else{ "[ERROR - $($k)]`t Nodes file not loaded: $($all_nodes_path)" | Out-File $SCRIPT_LOG -Append; continue}
		
		# array to hold all the different flows (D1, C1, C2...)
		$flow_category = @()
		try 
		{
			$flow_category_data = Import-CSV $flow_category_path 
			"[$($REGIONS[$j]) - $($k)]`t Import Flow Category" | Out-File $SCRIPT_LOG -Append
		}
		catch 
		{
			"[ERROR - $($k)]`t Unsuccessful attempt to open flow cats for $($flow_category_path)" | Out-File $SCRIPT_LOG -Append
			continue
		}
		

		# array to hold all node information
		$node_data = @()		
		try 
		{
			$node_data = Import-CSV $all_nodes_path
			"[$($REGIONS[$j]) - $($k)]`t Import all nodes" | Out-File $SCRIPT_LOG -Append
		}
		catch 
		{			
			"[ERROR - $($k)]`t Unsuccessful attempt to open all nodes for $($all_nodes_path)" | Out-File $SCRIPT_LOG -Append
			continue
		}
		
		# Turns off banned flows
		foreach ($fc in $flow_category_data)
		{
			if ($banned_flows -contains $fc.NAME)
			{
				$fc.CategoryActive = 0
				$model_info += "$($list_of_models_data[$k]),$($fc.NAME),"
				"[$($REGIONS[$j]) - $($k)]`t Turn off $($fc.NAME)" | Out-File $SCRIPT_LOG -Append
			}
			else
			{
				if ($fc.FlowCategoryType -eq "Volumetric" -and $fc.NAME -ne "Base Volumetric")
				{
					$flow_category += $fc.NAME
					$model_info += "$($list_of_models_data[$k]),,$($fc.NAME)"
					"[$($REGIONS[$j]) - $($k)]`t Keep $($fc.NAME)" | Out-File $SCRIPT_LOG -Append
				}
			}
		}
		
		
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
				"[ERROR - $($k)]`t Unsuccessful attempt to modify flow category $($flow_category[$i]) " | Out-File $SCRIPT_LOG -Append
			}
		}
		
		
		"[$($REGIONS[$j]) - $($k)]`t Export to file" | Out-File $SCRIPT_LOG -Append
			
		try
		{
			$flow_category_data | Export-CSV $flow_category_path -NoTypeInformation
			"[$($REGIONS[$j]) - $($k)]`t Write to flow cats successful $($flow_category_path)" | Out-File $SCRIPT_LOG -Append
		}
		catch
		{
			"[ERROR - $($k)]`t Unsuccessful attempt to write flow cats to $($flow_category_path)" | Out-File $SCRIPT_LOG -Append
		}
		
		try
		{
			$node_data | Export-CSV $all_nodes_path -NoTypeInformation
			"[$($REGIONS[$j]) - $($k)]`t Write to node data successful $($all_nodes_path)" | Out-File $SCRIPT_LOG -Append
		}
		catch
		{
			"[ERROR - $($k)]`t Unsuccessful attempt to write all node data to $($all_nodes_path)" | Out-File $SCRIPT_LOG -Append
		}
		
		try
		{
			$model_info | Out-File $model_info_out
		}
		catch
		{
			"[ERROR - $($k)]`t Could not write model info to file" | Out-File $SCRIPT_LOG -Append
		}
	}
	
}

"[SCRIPT]`t Script ended." | Out-File $SCRIPT_LOG -Append	