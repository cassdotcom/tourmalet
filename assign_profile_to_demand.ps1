function profile_check
{
	Param(
	[Parameter(Position=0, mandatory=$true)]
	[System.String]
	$list_of_models_file,
	[Parameter(Position=1, Mandatory=$false)]
	[System.Int32]
	$start_at,
	[Parameter(Position=2, Mandatory=$false)]
	[System.Int32]
	$stop_at)
	
	$out_path = 'G:\tourmalet\work_clone\S9_all_nodes\S9_profile_info.txt'
	$model_info_out = 'G:\tourmalet\work_clone\S9_all_nodes\S9_change_log.txt'
	try{
		$list_of_models_data = Get-Content $list_of_models_file
		}
	catch{
		Write-Warning "List contains no models: $($list_of_models_file)"
		break;
		}
	finally{
	
	write-host "after finally"
	
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
							'Fl1',
							'IH',
							'IL',
							'IM',
							'PL',
							'PL-90',
							'PL-BC',
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
		$flow_category_data = Import-CSV $flow_category_path 
		"$($k). Import Flow Category" | Out-File $out_path -Append

		# array to hold all node information
		$node_data = @()
		$node_data = Import-CSV $all_nodes_path
		"$($k). Import all nodes" | Out-File $out_path -Append
		
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
			

			$node_data | Where-Object { $_.$NodeFlowByCategory -ne ""} | Foreach-object { $_.$NodeFlowProfileNameByCategory = "$($flow_category[$i]) PROFILE"}
		}

		"$($k). Export to file" | Out-File $out_path -Append
		$flow_category_data | Export-CSV $flow_category_path -NoTypeInformation
		$node_data | Export-CSV $all_nodes_path -NoTypeInformation
	}
	
	$model_info | Out-File $model_info_out
	}
	
}

# Open flow categories:
# file paths
$list_of_models_file = 'G:\tourmalet\work_clone\S9_all_nodes\s9_list.txt'
$number_of_models = 2

profile_check($list_of_models_file)


# # # # # # # # $path = 'G:\tourmalet\ASP\files\643012_Broxburn_all_nodes.csv'

# # # # # # # # $model_node_data = Get-Content -Path $path | ForEach-Object {$_ -replace "\(", "_"} | ForEach-Object {$_ -replace "\)", "_"}
# # # # # # # # $model_node_data | Set-content $path

# # # # # # # # $all_nodes = Import-CSV $path
# # # # # # # # $D1_profiles = $all_nodes | where-object {$_.NodeFlowByCategory_D1_ -lt 0}

# # # # # # # # Write-host "There are $($D1_profiles.Count) D1 profiles"

# # # # # # # # $fixed_profiles = $all_nodes | where-object {$_.NodeFlowByCategory_D1_ -lt 0} | ForEach-Object {$_.NodeFlowProfileNameByCategory_D1_ -replace " ", "D1 PROFILE"}

# # # # # # # # $fixed_profiles | Set-content $path 
