$path = 'G:\tourmalet\ASP\files\643012_Broxburn_all_nodes.csv'

$model_node_data = Get-Content -Path $path | ForEach-Object {$_ -replace "\(", "_"} | ForEach-Object {$_ -replace "\)", "_"}
$model_node_data | Set-content $path

$all_nodes = Import-CSV $path
$D1_profiles = $all_nodes | where-object {$_.NodeFlowByCategory_D1_ -lt 0}

Write-host "There are $($D1_profiles.Count) D1 profiles"

$fixed_profiles = $all_nodes | where-object {$_.NodeFlowByCategory_D1_ -lt 0} | ForEach-Object {$_.NodeFlowProfileNameByCategory_D1_ -replace " ", "D1 PROFILE"}

$fixed_profiles | Set-content $path 
