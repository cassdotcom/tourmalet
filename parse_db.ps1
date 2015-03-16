$path = 'G:\tourmalet\4_3_2_models\models_4_3_2.accdb'

$tabname = "All_models_SORTED"
$regi = "East"
$region = "'$regi'"

$table = New-Object system.Data.DataTable "$tabname"
    #Define Columns
    $col1 = New-Object system.Data.DataColumn ID,([int])
    $col2 = New-Object system.Data.DataColumn modelpath,([string])
    $col3 = New-Object system.Data.DataColumn modelname,([string])
    $col4 = New-Object system.Data.DataColumn created,([string])
    $col5 = New-Object system.Data.DataColumn modified,([string])
    $col6 = New-Object system.Data.DataColumn accessed,([string])
    $col7 = New-Object system.Data.DataColumn length,([int])
    $col8 = New-Object system.Data.DataColumn readonly,([bool])
    $col9 = New-Object system.Data.DataColumn ldz,([string])
    $col10 = New-Object system.Data.DataColumn region,([string])
    $col11 = New-Object system.Data.DataColumn networkname,([string])
    $col12 = New-Object system.Data.DataColumn class,([string])
    $col13 = New-Object system.Data.DataColumn depth,([int])
	
    $table.columns.add($col1)
    $table.columns.add($col2)
    $table.columns.add($col3)
    $table.columns.add($col4)
    $table.columns.add($col5)
    $table.columns.add($col6)
	$table.columns.add($col7)
    $table.columns.add($col8)
    $table.columns.add($col9)
    $table.columns.add($col10)
    $table.columns.add($col11)
    $table.columns.add($col12)
    $table.columns.add($col13)
	
	
	$adOpenStatic = 3
	$adLockOptimistic = 3
	$cn = new-object -comobject ADODB.Connection
	$rs = new-object -comobject ADODB.Recordset
	
	$cn.Open("Provider = Microsoft.ACE.OLEDB.12.0;Data Source = $path")
	
	# Query database
	$rs.Open("SELECT * FROM [All_models_SORTED] WHERE [region] = $region", $cn, $adOpenStatic, $adLockOptimistic)
    # Count results
    $resultCount = $rs.RecordCount
    
    $rs.MoveFirst()
	
	for ($i=1; $i -le $resultCount; $i++)
    {    
                        
		$modelpath = $rs.Fields.Item("modelpath").Value 
		$modelname = $rs.Fields.Item("modelname").Value
		$networkname = $rs.Fields.Item("networkname").Value
		$class = $rs.Fields.Item("class").Value
		$depth = $rs.Fields.Item("depth").Value
			
		#Create a row
		$row = $table.NewRow()
		$row.ID = $i
		$row.modelpath = $modelpath
		$row.modelname = $modelname
		$row.networkname = $networkname
		$row.class = $class
		$row.depth = $depth
		
		$table.Rows.Add($row)
		
		$rs.MoveNext()
		
	}
	
	$rs.Close()
        
	$table | format-table -AutoSize 
	
	$table | export-csv "parse_db_return.csv" -notype