<#------------------------------------------------------------------------

	.FILE NAME
    ASSIGN_PROFILE_TO_DEMAND
	
    .PARAMETERS
    
    .DESCRIPTION
    Analyses the flow categories for a model
    Writes associated flow profile tag to node 
    
    .OUTPUT

    .VERSION
    0.2 - Modified header

------------------------------------------------------------------------#>
 
 	
process
{
	# Open flow categories:
	# file paths
	write-host "STARTING SCRIPT                                         " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	# write-host "                                                      " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	# write-host "      N1                                              " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	# $list_of_models_file = 'S:\TEST AREA\ac00418\average_system_pressures\settings\N1_model_list.txt'
	# $out_path = 'S:\TEST AREA\ac00418\average_system_pressures\logs\N1_profile_info.txt'
	# $model_info_out = 'S:\TEST AREA\ac00418\average_system_pressures\logs\N1_change_log.txt'
	# profile_check -models $list_of_models_file -info $out_path -log $model_info_out



	##
	# 				N2
	write-host "                                                      " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	write-host "      N2                                              " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	$list_of_models_file = 'S:\TEST AREA\ac00418\average_system_pressures\settings\N2_model_list.txt'
	$out_path = 'S:\TEST AREA\ac00418\average_system_pressures\logs\N2_profile_info.txt'
	$model_info_out = 'S:\TEST AREA\ac00418\average_system_pressures\logs\N2_change_log.txt'
	profile_check -models $list_of_models_file -info $out_path -log $model_info_out




	##
	# 				N3
	write-host "                                                      " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	write-host "      N3                                              " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	$list_of_models_file = 'S:\TEST AREA\ac00418\average_system_pressures\settings\N3_model_list.txt'
	$out_path = 'S:\TEST AREA\ac00418\average_system_pressures\logs\N3_profile_info.txt'
	$model_info_out = 'S:\TEST AREA\ac00418\average_system_pressures\logs\N3_change_log.txt'
	profile_check -models $list_of_models_file -info $out_path -log $model_info_out



	##
	# 				S1
	write-host "                                                      " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	write-host "      S1                                              " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	$list_of_models_file = 'S:\TEST AREA\ac00418\average_system_pressures\settings\S1_model_list.txt'
	$out_path = 'S:\TEST AREA\ac00418\average_system_pressures\logs\S1_profile_info.txt'
	$model_info_out = 'S:\TEST AREA\ac00418\average_system_pressures\logs\S1_change_log.txt'
	profile_check -models $list_of_models_file -info $out_path -log $model_info_out



	##
	# 				S2
	write-host "                                                      " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	write-host "      S2                                              " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	$list_of_models_file = 'S:\TEST AREA\ac00418\average_system_pressures\settings\S2_model_list.txt'
	$out_path = 'S:\TEST AREA\ac00418\average_system_pressures\logs\S2_profile_info.txt'
	$model_info_out = 'S:\TEST AREA\ac00418\average_system_pressures\logs\S2_change_log.txt'
	profile_check -models $list_of_models_file -info $out_path -log $model_info_out



	##
	# 				S8
	write-host "                                                      " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	write-host "      S8                                              " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	$list_of_models_file = 'S:\TEST AREA\ac00418\average_system_pressures\settings\S8_model_list.txt'
	$out_path = 'S:\TEST AREA\ac00418\average_system_pressures\logs\S8_profile_info.txt'
	$model_info_out = 'S:\TEST AREA\ac00418\average_system_pressures\logs\S8_change_log.txt'
	profile_check -models $list_of_models_file -info $out_path -log $model_info_out
} # END PROCESS

begin
{
	function profile_check
	{
		Param(
		[Parameter(Position=0, mandatory=$true)]
		[Alias("models")]
		[System.String]
		$list_of_models_file,
		[Parameter(Position=1, mandatory=$true)]
		[Alias("info")]
		[System.String]
		$out_path,
		[Parameter(Position=2, mandatory=$true)]
		[Alias("log")]
		[System.String]
		$model_info_out,
		[Parameter(Position=3, Mandatory=$false)]
		[System.Int32]
		$start_at,
		[Parameter(Position=4, Mandatory=$false)]
		[System.Int32]
		$stop_at)
		
		$ErrorActionPreference = 'Stop'
		
		# # # # # $out_path = 'S:\TEST AREA\ac00418\average_system_pressures\logs\N1_profile_info.txt'
		# # # # # $model_info_out = 'S:\TEST AREA\ac00418\average_system_pressures\logs\N1_change_log.txt'
		try{
			$list_of_models_data = Get-Content $list_of_models_file
			}
		catch{
			Write-Warning "List contains no models: $($list_of_models_file)" | Out-File $out_path
			break;
			}
		finally{
		}
		
		$model_info = @()
		
		$list_of_models_file | Out-File $out_path
		$number_of_models = $list_of_models_data.length 
		$number_of_models | Out-File $out_path -Append
			
		for($k=0;$k -lt $number_of_models; $k++)
		{
			write-progress -Activity 'Sort Profiles' -status "Progress:" -percentcomplete ($k/$number_of_models*100) -id 0 -currentoperation $list_of_models_data[$k]
			$flow_category_path = "$($list_of_models_data[$k])_flow_categories.csv"
			$all_nodes_path = "$($list_of_models_data[$k])_all_nodes.csv"
			$list_of_models_data[$k] | Out-File $out_path -Append
			$banned_flows = @(	'CH',
								'CL',
								'CM',
								'DH',
								'DL',
								'DM',
								'IH',
								'IL',
								'IM',
								'PL',
								'PL-90',
								'PL-D2',
								'PL-D3',
								'PL-DC',
								'PL-CC',
								'PL-J1',
								'PL-M',
								'PL-PL',
								'PL-V',
								'PL-VD',
								'PL-VN',
								'SH',
								'SL',
								'SM',
								'TH',
								'TL',
								'TM')




			# array to hold all the different flows (D1, C1, C2...)
			$flow_category = @()
			try {
				$flow_category_data = Import-CSV $flow_category_path 
				"$($k). Import Flow Category" | Out-File $out_path -Append
			}
			catch {
				write-warning "$($k). £ Unsuccessful attempt to open flow cats for $($flow_category_path) #######################" | Out-File $out_path -Append
				continue
			}
			finally {
			}

			# array to hold all node information
			$node_data = @()
			
			try {
				$node_data = Import-CSV $all_nodes_path
				"$($k). Import all nodes" | Out-File $out_path -Append
			}
			catch {			
				write-warning "$($k). £ Unsuccessful attempt to open all nodes for $($all_nodes_path) #######################" | Out-File $out_path -Append
				continue
			}
			finally {
			}
			
			# Switch off non-core profiles
			# Core: D1, C1, C2, C3, C4, I2, DC, CC, IC, PL-AF
			# Banned: All PL-, DL, DM, DH, CL, CM, CH, IL, IM, IH, 
			# # # # NAME                            : DC
			# # # # TYPE                            : Flow Categories
			# # # # FlowCategoryTotalVolumetricFlow : -21.690001
			# # # # FlowCategoryTotalThermalFlow    : 0.000000
			# # # # FlowCategoryMultiplier          : 1.000000
			# # # # FlowCategoryType                : Volumetric
			# # # # CategoryActive                  : -1.000000

			# Turns off banned flows
			foreach ($fc in $flow_category_data)
			{
				if ($banned_flows -contains $fc.NAME)
				{
					$fc.CategoryActive = 0
					$model_info += "$($list_of_models_data[$k]),$($fc.NAME),"
					"$($k). Turn off $($fc.NAME)" | Out-File $out_path -Append
				}
				else
				{
					if ($fc.FlowCategoryType -eq "Volumetric" -and $fc.NAME -ne "Base Volumetric")
					{
						$flow_category += $fc.NAME
						$model_info += "$($list_of_models_data[$k]),,$($fc.NAME)"
						"$($k). Keep $($fc.NAME)" | Out-File $out_path -Append
					}
				}
			}


			$flow_category_count = $flow_category.count
			# write-warning "There are $($flow_category_count) flow categories"

			for ($i = 0; $i -lt $flow_category_count; $i++)
			{
				$NodeFlowByCategory = "NodeFlowByCategory($($flow_category[$i]))"
				$NodeFlowProfileNameByCategory = "NodeFlowProfileNameByCategory($($flow_category[$i]))"
				
				try {
					$node_data | Where-Object { $_.$NodeFlowByCategory -ne ""} | Foreach-object { $_.$NodeFlowProfileNameByCategory = "$($flow_category[$i]) PROFILE"}
					}
				catch {
					write-warning "$($k) @Unsuccessful attempt to modify flow category $($flow_category[$i]) "
					"$($list_of_models_data[$k]) @Unsuccessful attempt to modify flow category $($flow_category[$i]) " | Out-File $out_path -Append
					}
				finally {
					}
			}

			"$($k). Export to file" | Out-File $out_path -Append
			
			try {
				$flow_category_data | Export-CSV $flow_category_path -NoTypeInformation
			}
			catch {
				write-warning "$($k). @Unsuccessful attempt to write flow cats to $($flow_category_path) #######################" | Out-File $out_path -Append
			}
			finally {
			}
			
			try {
				$node_data | Export-CSV $all_nodes_path -NoTypeInformation
			}
			catch {
				write-warning "$($k). @Unsuccessful attempt to write all node data to $($all_nodes_path) #######################" | Out-File $out_path -Append
			}
			finally {
			}
		}
		
		$model_info | Out-File $model_info_out
	}
} # END BEGIN

end
{
	write-host " END SCRIPT                                           " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
	write-host " SEE S:\TEST AREA\ac00418\average_system_pressures\logs\ FOR LOGS                  " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
} # END END


# write-host "                                                      " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
# write-host "      S9                                              " -foregroundcolor 'darkgreen' -backgroundcolor 'white'
# $list_of_models_file = 'S:\TEST AREA\ac00418\average_system_pressures\settings\S9_model_list.txt'
# $out_path = 'S:\TEST AREA\ac00418\average_system_pressures\logs\S9_profile_info.txt'
# $model_info_out = 'S:\TEST AREA\ac00418\average_system_pressures\logs\S9_change_log.txt'

# profile_check -models $list_of_models_file -info $out_path -log $model_info_out


# # # # # # # # $path = 'G:\tourmalet\ASP\files\643012_Broxburn_all_nodes.csv'

# # # # # # # # $model_node_data = Get-Content -Path $path | ForEach-Object {$_ -replace "\(", "_"} | ForEach-Object {$_ -replace "\)", "_"}
# # # # # # # # $model_node_data | Set-content $path

# # # # # # # # $all_nodes = Import-CSV $path
# # # # # # # # $D1_profiles = $all_nodes | where-object {$_.NodeFlowByCategory_D1_ -lt 0}

# # # # # # # # Write-host "There are $($D1_profiles.Count) D1 profiles"

# # # # # # # # $fixed_profiles = $all_nodes | where-object {$_.NodeFlowByCategory_D1_ -lt 0} | ForEach-Object {$_.NodeFlowProfileNameByCategory_D1_ -replace " ", "D1 PROFILE"}

# # # # # # # # $fixed_profiles | Set-content $path 
