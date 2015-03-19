$root = (Get-Item '\\vpoct502\Syn471\Scotland Networks_471\North_471\').FullName
$file_out = 'S:\TEST AREA\ac00418\logs\4_7_1_Models\North_index.txt'

Get-ChildItem $root -recurse | where { $_.PSIsContainer -eq $false} |% { 
	$relPath = $_.FullName.Remove(0, $root.Length + 1)
	Write-Output $relPath >> $file_out
	}
