$path = "G:\github_clone\tourmalet\model_extracts\flows\"

$regions=@(	"N1",
			"N2",
			"N3",
			"S1",
			"S2",
			"S6S7",
			"S8",
			"S9")
			
for ($i=0; $i -lt 8; $i++)
{
	$op_path = $path + $regions[$i] + "_all_nodes\"
	$file_list = gci $op_path | Select Name
	$op = $path + $regions[$i] + "_model_list.txt"
	$file_list >> $op
	
	write-host "FINISHED $($regions[$i])" -foregroundcolor "black" -backgroundcolor "yellow"
}	