<#	------------------------------------------------------------------------
	FILE NAME: asp_outline.ps1
	PARAMETERS: None
	
	AVERAGE SYSTEM PRESSURE: DISABLE SUBSYSTEMS
		Takes exchange file from Synergee with identified subsystems
		Finds all plastic subsystems
		Sets service state of pipes in all plastic subsystems to 'Disabled'
		Modifies exchange file.
 
 
	For logging purposes:
                [#] - indicates model name
                [@] - indicates model filepath
                [8] - indicates subsystem
                [~] - indicates ASP 
	
	------------------------------------------------------------------------#>
	
<# 
	USE THIS AREA TO DECLARE ANY CONSTANTS NOT IN SETTINGS FILE ETC...
																										#>
# FAILSAFE ERROR HANDLING
# If script / transcript fails, this file will still catch it.
# Saves in local directory - ie where this script is saved
$ERROR_LOG = 'catch_errors.txt'

# GET DATE AND TIMES
$TIMES = Get-Date -format yyyy-mm-dd_hh-mm-ss
$SLEEP_FOR = $h.Get_Item("sleep_for")




<#------------------------------------------------------------------------------------------------------->
 
	FIND SETTINGS FILE
		Try to make this the same file that Synergee uses, to cut down on files.
		
<-------------------------------------------------------------------------------------------------------#>