###########################################################
# FILE		: examine_subsystems
# AUTHOR  	: A. Cassidy 
# DATE    	: 2015-03-22 
# EDIT    	: 
# COMMENT 	:  
#             
#           
# VERSION : 1.0
###########################################################
# 
# CHANGELOG
# Version 1.0:


###########################################################
#
#region SETUP
#
###########################################################
#
#----------------------------------------------------------
#STATIC VARIABLES
#----------------------------------------------------------
$settings_file	= "G:\github_clone\tourmalet\settings\examine_subsystems_settings.ini"
$TIMES = Get-Date -format yyyy-MM-dd_hh-mm-ss

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
	write-progress -Activity 'Examine Subsystems' -status "Processsing Regions" -percentcomplete ($j/8*100) -id 0 -currentoperation $REGIONS[$j]
	"[$($REGIONS[$j])]`t`tBegin models in $($REGIONS[$j])" | Out-File $SCRIPT_LOG -Append
	
	#----------------------------------------------------------
    # Get models from list
    #----------------------------------------------------------
	$list_of_models_file = $h.Get_Item("$($REGIONS[$j])_asp_report.txt")
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

