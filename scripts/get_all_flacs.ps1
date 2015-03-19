$FLACPath = 'G:\Users\cass\Music\FLAC'


$flac_contents = Get-ChildItem -Path $FLACPath -Recurse
$folders = $flac_contents | where-object { $_.PSIsContainer }

$number_of_folders = $folders.count


write-host "There are $number_of_folders albums"


Get-ChildItem -Path $FLACPath -Filter *.flac -Recurse | Select-Object directoryname,basename,length | Export-Csv -Path G:\Users\cass\Music\FLAC\pshell_flac_index.csv -Encoding ascii -NoTypeInformation

Invoke-Item G:\Users\cass\Music\FLAC\pshell_flac_index.csv


# $bb = Get-ChildItem -Filter *.flac -Recurse | Select-Object directoryname,basename,length
# $track = $bb[0].basename


# $regex = '[\d\d]'
# $re = $track | select-string -Pattern $regex -AllMatches | % { $_.Matches } | % {$_.Value}
 
 write-progress -Activity 'Find Model Paths' -status "Progress:" -percentcomplete ($counterm/$ldz_list.count*100) -id 0 -currentoperation $models_in

                write-host $models_in -ForegroundColor Red -BackgroundColor White -NoNewLine
				
				