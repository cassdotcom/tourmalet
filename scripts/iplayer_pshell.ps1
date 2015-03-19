write-host " "
write-host " "
write-host " "
write-host "----------------------------------"
write-host "Get_iPlayer Powershell script v1.0"
write-host " "

$TO_RECORD_FILE = "C:\Users\jjc\Desktop\iPlayer Recordings\to_record\to_record.txt"
$TO_RECORD_FILE_YESTERDAY = "C:\Users\jjc\Desktop\iPlayer Recordings\to_record\to_record_YESTERDAY.txt"
$prog_url_list = @()

# Construct command line
write-host "Construct command line..........." -NoNewLine
$pid_construct1 = '--pid='
$pid_construct2 = ' --force --thumb --subdir --whitespace --subtitles --modes=best --file-prefix="<brand> - <senum> - <episodeshort>" --playlist-metadata --metadata generic'
$perl_exe = "'C:\Program Files (x86)\get_iplayer\perl.exe'"
$perl_script = "'C:\Program Files (x86)\get_iplayer\get_iplayer.pl'"
write-host "DONE"

# open to record file
write-host "Open recording logs.........." -NoNewLine
$to_record_list = Get-Content $TO_RECORD_FILE
$already_recorded = Get-Content $TO_RECORD_FILE_YESTERDAY
write-host "DONE"

write-host "Compare record list with previous downloads.........." -NoNewLine
$to_record = Compare-Object $to_record_list $already_recorded | ?{$_.SideIndicator -eq "<="} | ForEach-Object { $_.InputObject }
write-host "DONE"

if (!([string]::IsNullOrEmpty($to_record))){
	foreach ($prog_url in $to_record){
	
		# $out_file = "C:\get_iplayer_pshell_OUT_$prog_pid.txt"
		# $error_file = "C:\get_iplayer_pshell_ERROR_$prog_pid.txt"
		# $pid_pass = "$perl_exe $perl_script $pid_construct1$prog_pid $pid_construct2"
		
		# find the pid
		$find_pid_perl = 'C:\Users\jjc\Desktop\iPlayer Recordings\find_pid.pl'
		$prog_pid = perl $find_pid_perl $prog_url
		write-host "Download $prog_pid"
		
		$pid_pass = "perl $perl_script $pid_construct1$prog_pid $pid_construct2"

		invoke-expression $pid_pass
		# start-process 'get_iplayer.cmd $pid_pass'
		write-host "----------------------------------"
		write-host "DONE"
		write-host "----------------------------------"
		
		$prog_url_list += $prog_url
	}
	
	$prog_url_list | Out-File -filepath $TO_RECORD_FILE_YESTERDAY -Append
	$to_record_list | Where-Object {$_ -notmatch $prog_url_list} | Set-Content $TO_RECORD_FILE
}
else {
	write-host "NO NEW FILES TO RECORD !!!!!!!!!!!!!!"
}

# stop-process -Id $PID