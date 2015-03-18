<#
	.SYNOPSIS
		Analyse Synergee LOC file.

	.DESCRIPTION
		Takes path to Synergee LOC file and returns owner and other LOC-held information 

	.PARAMETER  $LOC_path
		Path to LOC file.

	.EXAMPLE
		PS C:\> read_loc_file -location "\Edinburgh FY1\Edinburgh FY1_MDB.LOC"
		Owner: Andy Cassidy
		Last Modified: 01/23/2015 14:04:00

	.INPUTS
		System.String

	.OUTPUTS
		System.String,System.String

	.NOTES
		For more information about advanced functions, call Get-Help with any
		of the topics in the links listed below.

	.LINK
		about_functions_advanced

	.LINK
		about_comment_based_help
#>
<#	------------------------------------------------------------------------
	FILE NAME: read_loc_file.ps1
	PARAMETERS: 
	
	READ LOC FILE
		Takes path to Synergee LOC file
		Returns owner and other LOC-held information               
 
	For logging purposes:
                [#] - indicates model name
                [@] - indicates model filepath
                [8] - indicates subsystem
                [~] - indicates ASP 
	
	------------------------------------------------------------------------#>
param (
	[Parameter(Position=0, mandatory=$true)]
	[Alias("location")]
	[System.String]
	$LOC_path
)

$ErrorActionPreference = 'Stop'

try {
	if (Test-Path $LOC_path)
	{
		$owner = (get-content $LOC_path)[0]
		$date = (get-content $LOC_path)[2]
		write-host "OWNER: $($owner)" -foregroundcolor 'darkmagenta' -backgroundcolor 'white'
		write-host "LAST MODIFIED: $($date)" -foregroundcolor 'darkmagenta' -backgroundcolor 'white'
	}
	else
	{
		write-warning "LOC File not found!"
		$owner = "UNKNOWN USER"
		$date = "UNKNOWN DATE"
		return
	}
} # end try
catch {
	write-error "UNABLE TO PARSE LOC FILE"
	write-error "PLEASE ENSURE FILE EXISTS IN THIS LOCATION: $($LOC_path)"
} # end catch
finally { 
} # end finally
	
	
	
			
<# 
	USE THIS AREA TO DECLARE ANY CONSTANTS NOT IN SETTINGS FILE ETC...
																										#>
# FAILSAFE ERROR HANDLING
# If script / transcript fails, this file will still catch it.
# Saves in local directory - ie where this script is saved
$ERROR_LOG = 'catch_errors.txt'




<#------------------------------------------------------------------------------------------------------->
 
	FIND SETTINGS FILE
		Try to make this the same file that Synergee uses, to cut down on files.
		
<-------------------------------------------------------------------------------------------------------#>

