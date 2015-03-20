# Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Get list of models to check
$model_list_file = "H:\Synergee Work Group\4_7\conversion\check_mdb_SOE_IN.txt"
# Read file contents
$model_list = Get-Content $model_list_file
# Output file
$output_file = "H:\Synergee Work Group\4_7\conversion\check_mdb_SOE_OUT.txt"

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

# Get list of models to check
$model_list_file = "H:\Synergee Work Group\4_7\conversion\check_mdb_Validation_IN.txt"
# Read file contents
$model_list = Get-Content $model_list_file
# Output file
$output_file = "H:\Synergee Work Group\4_7\conversion\check_mdb_Validation_OUT.txt"

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

# Get list of models to check
$model_list_file = "H:\Synergee Work Group\4_7\conversion\check_mdb_LRMM_IN.txt"
# Read file contents
$model_list = Get-Content $model_list_file
# Output file
$output_file = "H:\Synergee Work Group\4_7\conversion\check_mdb_LRMM_OUT.txt"

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

# Get list of models to check
$model_list_file = "H:\Synergee Work Group\4_7\conversion\check_mdb_WOP_IN.txt"
# Read file contents
$model_list = Get-Content $model_list_file
# Output file
$output_file = "H:\Synergee Work Group\4_7\conversion\check_mdb_WOP_OUT.txt"

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
	

		
