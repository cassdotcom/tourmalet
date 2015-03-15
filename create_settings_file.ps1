<#
.SYNOPSIS
creates settings file

.DESCRIPTION
creates synergee / powershell settings files

.PARAMETER $ldz
either LRMM / WOP / SC / SOE

.PARAMETER $region
North / West / East / S1 (80) district LP models / S2 (82) district LP models / S6 (90) and S7 (92) district LP models / S8 (94) district LP models / S9 (96) district LP models

.INPUTS
.OUTPUTS
.EXAMPLE
.EXAMPLE
.LINK
#>
# function create_settings_file
# {
		# Param (
		# [ValidateNotNull()]
		# [Parameter(Mandatory = $true)]
		# [string]$ldz,
		# [ValidateNotNull()]
		# [Parameter(Mandatory = $true)]
		# [string]$region
	# )
	
	$loc_out = "S:\TEST AREA\ac00418\average_system_pressures\outputs\loc_files.txt"
	# $ldz = 'SCT'
	# $region = 'N1'
	
	# LDZ selection
	Try 
	{
		# Pick modelpaths based on user ldz selection
		switch ($ldz)
		{
			'SCT' { write-host "SCT"; $model_folder = "\\vpoct502\Syn471\Scotland Networks_471\" }
			'SOE' { write-host "SOE";$model_folder = "\\vpoct502\Syn471\Southern Networks_471\" }
			'WOP' { write-host "WOP";$model_folder = "\\vpoct502\Syn471\WOP 14-15_471\" }
			'LRM' { write-host "LRM";$model_folder = "\\vpoct502\Syn471\LRMM_471\" }
			default { throw $error[0].exception }
		}
	}
	Catch 
	{
		Write-Warning "No LDZ selected"
	}
	Finally 
	{
		write-host "Continue"
	}
	
	
	# Region selection
	try
	{
		switch ($region)
		{
			'N1' { write-host "N1";$region_path = "North_471\" }
			'N2' { write-host "N2";$region_path = "West_471\" }
			'N3' { write-host "N3";$region_path = "East_471-v2\" }
			'S1' { $region_path = "S1 (80) district LP models_471\" }
			'S2' { $region_path = "S2 (82) district LP models_471\" }
			'S6' { $region_path = "S6 (90) and S7 (92) district LP models_471\" }
			'S7' { $region_path = "S6 (90) and S7 (92) district LP models_471\" }
			'S8' { $region_path = "S8 (94) district LP models_471\" }
			'S9' { $region_path = "S9 (96) district LP models_471\" }
			default { throw $error[0].exception }
		}
	}
	catch
	{
		Write-Warning "No Region selected"
	}
	Finally 
	{
		$model_path = $model_folder + $region_path
	}
	
	$model_list = Get-ChildItem $model_path
	
	$i = 1
	$total_model_list = $model_list.count
	
	foreach($model in $model_list)
	{
		write-progress -Activity 'Find LOC' -status "Progress:" -percentcomplete ($i/$total_model_list*100) -id 1 -currentoperation $model
		
		$path_exists = Test-Path $model.FullName
		
		if ($path_exists)
		{
			$loc_files = Get-ChildItem $model.FullName -Recurse -force -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.LOC") } | Select-Object FullName >> $loc_out
		}
		else
		{
			write-warning "$model doesn't exist"
		}
		$i++
	}
	
	
# }
	
