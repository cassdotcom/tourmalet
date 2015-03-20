# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Get list of models to check
$model_list_file = "\\scotia.sgngroup.net\dfs\shared\Syn4.2.3\TEST AREA\ac00418\logs\convertedModelLog.txt"
# Read file contents
$model_list = Get-Content $model_list_file
# Output file
$output_file = "\\scotia.sgngroup.net\dfs\shared\Syn4.2.3\TEST AREA\ac00418\logs\convertedModelLog_checked.txt"

# How many models
$model_count = $model_list.Count

# Headers
$heads = "ID,Filepath,ProductVersion,SchemaVersion,Corrupt"
Write-Output $heads > $output_file
$i = 1

# Loop through every model and find version number
foreach ($path in $model_list)
{
	# General database setup
	$adOpenStatic = 3
	$adLockOptimistic = 3
	$cn = new-object -comobject ADODB.Connection
	$rs = new-object -comobject ADODB.Recordset
	$sy = new-object -comobject ADODB.Recordset
	
	# Assume it didn't corrupt
	$corrupt = "NO"	
	
	$cn.Open("Provider = Microsoft.Jet.OLEDB.4.0;Data Source = $path")
	
	# Query database
	$rs.Open("SELECT * FROM [VersionInfo]", $cn, $adOpenStatic, $adLockOptimistic)
	$rs.MoveFirst()
	$version = $rs.Fields.Item("ProductVersion").Value 
	$schema = $rs.Fields.Item("SchemaVersion").Value
	
	# 
	$sy.Open("SELECT * FROM [Node] WHERE [Node].[SymbolId] IS NOT NULL", $cn, $adOpenStatic, $adLockOptimistic)
	# $sy.MoveLast()
	# $sy.MoveNext()
	
	$node_symbol = $sy.RecordCount	
	if ($node_symbol -eq 0)
	{
		$corrupt = "YES"
		}
	
	$result = "$($i),$($path),$($version),$($schema),$($corrupt)"
	Write-Output $result >> $output_file
	Write-Host $result 
	
	$i++
	
	}
	
#########################################################################
#
#########################################################################
