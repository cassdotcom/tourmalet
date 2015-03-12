
##########################################################################################################################
##########################################################################################################################

##########################################################################################################################
##########################################################################################################################

Write-Warning "N1"
$path = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\N1.csv'
$path_valid = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\N1_valid.csv'
$path_not_valid = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\N1_not_valid.csv'
$west = (Get-Content $path)
$end_point = $west.count

$number_of_valid = 0
$number_of_not_valid = 0

$modelpath_valid = @()
$modelpath_notvalid = @()

for ( $i = 0; $i -lt $end_point; $i++ )
{
	$modelpath = $($west[$i].Split(","))[-1]
	$modelname = $($west[$i].Split(","))[-4]
	
	write-progress -Activity 'Testing modelpath' -status "Progress:" -percentcomplete ((($i+1)/($end_point+1))*100) -id 0 -currentoperation $modelname
	
	if ( Test-Path $modelpath)
	{
		$modelsin = "Model$($number_of_valid+1)=$($modelpath)"
		$modelsname = "ModelName$($number_of_valid+1)=$($modelname)"
		$modelsout = "ModelOut$($number_of_valid+1)=S:\TEST AREA\ac00418\ASP_models_out\$($modelname)_LRMM1415.MDB"
		
		$modelpath_valid += "$($modelsin),$($modelsname),$($modelsout)"
		$number_of_valid++
	}
	else
	{
		$modelpath_notvalid += $modelpath
		$number_of_not_valid++
	}
	
}

write-host "VALID: $($number_of_valid)"
write-host "NOT VALID: $($number_of_not_valid)"

$modelpath_valid | Out-File $path_valid
$modelpath_notvalid | Out-File $path_not_valid

# # # # # # # # # # # # ##########################################################################################################################
# # # # # # # # # # # # ##########################################################################################################################

# # # # # # # # # # # # ##########################################################################################################################
# # # # # # # # # # # # ##########################################################################################################################
# # # # # # # # # # # # Write-Warning "S8"
# # # # # # # # # # # # $path = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\S8.csv'
# # # # # # # # # # # # $path_valid = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\S8_valid.csv'
# # # # # # # # # # # # $path_not_valid = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\S8_not_valid.csv'
# # # # # # # # # # # # $west = (Get-Content $path)
# # # # # # # # # # # # $end_point = $west.count

# # # # # # # # # # # # $number_of_valid = 0
# # # # # # # # # # # # $number_of_not_valid = 0

# # # # # # # # # # # # $modelpath_valid = @()
# # # # # # # # # # # # $modelpath_notvalid = @()

# # # # # # # # # # # # for ( $i = 0; $i -lt $end_point; $i++ )
# # # # # # # # # # # # {
	# # # # # # # # # # # # $modelpath = $($west[$i].Split(","))[-1]
	# # # # # # # # # # # # $modelname = $($west[$i].Split(","))[-4]
	
	# # # # # # # # # # # # write-progress -Activity 'Testing modelpath' -status "Progress:" -percentcomplete ((($i+1)/($end_point+1))*100) -id 0 -currentoperation $modelname
	
	# # # # # # # # # # # # if ( Test-Path $modelpath)
	# # # # # # # # # # # # {
		# # # # # # # # # # # # $modelsin = "Model$($number_of_valid+1)=$($modelpath)"
		# # # # # # # # # # # # $modelsname = "ModelName$($number_of_valid+1)=$($modelname)"
		# # # # # # # # # # # # $modelsout = "ModelOut$($number_of_valid+1)=S:\TEST AREA\ac00418\ASP_models_out\$($modelname)_LRMM1415.MDB"
		
		# # # # # # # # # # # # $modelpath_valid += "$($modelsin),$($modelsname),$($modelsout)"
		# # # # # # # # # # # # $number_of_valid++
	# # # # # # # # # # # # }
	# # # # # # # # # # # # else
	# # # # # # # # # # # # {
		# # # # # # # # # # # # $modelpath_notvalid += $modelpath
		# # # # # # # # # # # # $number_of_not_valid++
	# # # # # # # # # # # # }
	
# # # # # # # # # # # # }

# # # # # # # # # # # # write-host "VALID: $($number_of_valid)"
# # # # # # # # # # # # write-host "NOT VALID: $($number_of_not_valid)"

# # # # # # # # # # # # $modelpath_valid | Out-File $path_valid
# # # # # # # # # # # # $modelpath_notvalid | Out-File $path_not_valid




# # # # # # # # # # # # ##########################################################################################################################
# # # # # # # # # # # # ##########################################################################################################################

# # # # # # # # # # # # ##########################################################################################################################
# # # # # # # # # # # # ##########################################################################################################################
# # # # # # # # # # # # Write-Warning "S9"
# # # # # # # # # # # # $path = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\S9.csv'
# # # # # # # # # # # # $path_valid = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\S9_valid.csv'
# # # # # # # # # # # # $path_not_valid = 'S:\TEST AREA\ac00418\average_system_pressures\4_7_models\S9_not_valid.csv'
# # # # # # # # # # # # $west = (Get-Content $path)
# # # # # # # # # # # # $end_point = $west.count

# # # # # # # # # # # # $number_of_valid = 0
# # # # # # # # # # # # $number_of_not_valid = 0

# # # # # # # # # # # # $modelpath_valid = @()
# # # # # # # # # # # # $modelpath_notvalid = @()

# # # # # # # # # # # # for ( $i = 0; $i -lt $end_point; $i++ )
# # # # # # # # # # # # {
	# # # # # # # # # # # # $modelpath = $($west[$i].Split(","))[-1]
	# # # # # # # # # # # # $modelname = $($west[$i].Split(","))[-4]
	
	# # # # # # # # # # # # write-progress -Activity 'Testing modelpath' -status "Progress:" -percentcomplete ((($i+1)/($end_point+1))*100) -id 0 -currentoperation $modelname
	
	# # # # # # # # # # # # if ( Test-Path $modelpath)
	# # # # # # # # # # # # {
		# # # # # # # # # # # # $modelsin = "Model$($number_of_valid+1)=$($modelpath)"
		# # # # # # # # # # # # $modelsname = "ModelName$($number_of_valid+1)=$($modelname)"
		# # # # # # # # # # # # $modelsout = "ModelOut$($number_of_valid+1)=S:\TEST AREA\ac00418\ASP_models_out\$($modelname)_LRMM1415.MDB"
		
		# # # # # # # # # # # # $modelpath_valid += "$($modelsin),$($modelsname),$($modelsout)"
		# # # # # # # # # # # # $number_of_valid++
	# # # # # # # # # # # # }
	# # # # # # # # # # # # else
	# # # # # # # # # # # # {
		# # # # # # # # # # # # $modelpath_notvalid += $modelpath
		# # # # # # # # # # # # $number_of_not_valid++
	# # # # # # # # # # # # }
	
# # # # # # # # # # # # }

# # # # # # # # # # # # write-host "VALID: $($number_of_valid)"
# # # # # # # # # # # # write-host "NOT VALID: $($number_of_not_valid)"

# # # # # # # # # # # # $modelpath_valid | Out-File $path_valid
# # # # # # # # # # # # $modelpath_notvalid | Out-File $path_not_valid








# # # # # # $ldz = @()
# # # # # # $ldz += 'SCT'
# # # # # # $ldz += 'SOE'

# # # # # # $region = @()
# # # # # # $region += 'N1'
# # # # # # $region += 'N2'
# # # # # # $region += 'N3'
# # # # # # $region += 'S1'
# # # # # # $region += 'S2'
# # # # # # $region += 'S6'
# # # # # # $region += 'S8'
# # # # # # $region += 'S9'

# # # # # # $i = 0
# # # # # # $j = 0

# # # # # # for ( $i = 0; $i -lt 2; $i++ )
# # # # # # {
	# # # # # # for ( $j = 0; $j -lt 8; $j++ )
	# # # # # # {
		# # # # # # write-progress -Activity 'Find LOC' -status "Progress:" -percentcomplete ((($j+1)/8)*100) -id 0 -currentoperation $region[$j]
		# # # # # # # Start-Process -FilePath ".\create_settings_file.ps1" -Argumentlist "/f '$ldz[$i] $region[$j]'" -NoNewWindow -Wait 
		# # # # # # .\create_settings_file.ps1 $ldz[$i] $region[$j] | Wait-Process 
	# # # # # # }
# # # # # # }








# # # # # # function create_settings_file
# # # # # # {
		# # # # # # Param (
		# # # # # # [ValidateNotNull()]
		# # # # # # [Parameter(Mandatory = $true)]
		# # # # # # [string]$ldz,
		# # # # # # [ValidateNotNull()]
		# # # # # # [Parameter(Mandatory = $true)]
		# # # # # # [string]$region
 # # # # # # )
	
	# # # # # # $loc_out = "S:\TEST AREA\ac00418\average_system_pressures\outputs\loc_files.txt"
	# # # # # # # $ldz = 'SCT'
	# # # # # # # $region = 'N1'
	
	# # # # # # # LDZ selection
	# # # # # # Try 
	# # # # # # {
		# # # # # # # Pick modelpaths based on user ldz selection
		# # # # # # switch ($ldz)
		# # # # # # {
			# # # # # # 'SCT' { write-host "SCT"; $model_folder = "\\vpoct502\Syn471\Scotland Networks_471\" }
			# # # # # # 'SOE' { write-host "SOE"; $model_folder = "\\vpoct502\Syn471\Southern Networks_471\" }
			# # # # # # 'WOP' { write-host "WOP"; $model_folder = "\\vpoct502\Syn471\WOP 14-15_471\" }
			# # # # # # 'LRM' { write-host "LRM"; $model_folder = "\\vpoct502\Syn471\LRMM_471\" }
			# # # # # # default { throw $error[0].exception }
		# # # # # # }
	# # # # # # }
	# # # # # # Catch 
	# # # # # # {
		# # # # # # Write-Warning "No LDZ selected"
	# # # # # # }
	# # # # # # Finally 
	# # # # # # {
		# # # # # # write-host "Continue"
	# # # # # # }
	
	
	# # # # # # # Region selection
	# # # # # # try
	# # # # # # {
		# # # # # # switch ($region)
		# # # # # # {
			# # # # # # 'N1' { write-host "N1";$region_path = "North_471\" }
			# # # # # # 'N2' { write-host "N2";$region_path = "West_471\" }
			# # # # # # 'N3' { write-host "N3";$region_path = "East_471-v2\" }
			# # # # # # 'S1' { $region_path = "S1 (80) district LP models_471\" }
			# # # # # # 'S2' { $region_path = "S2 (82) district LP models_471\" }
			# # # # # # 'S6' { $region_path = "S6 (90) and S7 (92) district LP models_471\" }
			# # # # # # 'S7' { $region_path = "S6 (90) and S7 (92) district LP models_471\" }
			# # # # # # 'S8' { $region_path = "S8 (94) district LP models_471\" }
			# # # # # # 'S9' { $region_path = "S9 (96) district LP models_471\" }
			# # # # # # default { throw $error[0].exception }
		# # # # # # }
	# # # # # # }
	# # # # # # catch
	# # # # # # {
		# # # # # # Write-Warning "No Region selected"
	# # # # # # }
	# # # # # # Finally 
	# # # # # # {
		# # # # # # $model_path = $model_folder + $region_path
	# # # # # # }
	
	# # # # # # $model_list = Get-ChildItem $model_path
	
	# # # # # # $i = 1
	# # # # # # $total_model_list = $model_list.count
	
	# # # # # # foreach($model in $model_list)
	# # # # # # {
		# # # # # # write-progress -Activity 'Find LOC' -status "Progress:" -percentcomplete ($i/$total_model_list*100) -id 1 -currentoperation $model
		
		# # # # # # $path_exists = Test-Path $model.FullName
		
		# # # # # # if ($path_exists)
		# # # # # # {
			# # # # # # $loc_files = Get-ChildItem $model.FullName -Recurse -force -ErrorAction SilentlyContinue | Where-Object { ($_.PSIsContainer -eq $false) -and  ( $_.Name -like "*.LOC") } | Select-Object FullName >> $loc_out
		# # # # # # }
		# # # # # # else
		# # # # # # {
			# # # # # # write-warning "$model doesn't exist"
		# # # # # # }
		# # # # # # $i++
	# # # # # # }
	
	
# # # # # # }
	
