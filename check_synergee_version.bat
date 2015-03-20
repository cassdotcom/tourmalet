set file_in=%1
set file_out=%2
set pshell_script=H:\sendMail4.ps1^ %file_in% %file_out%
set comm_str=-ExecutionPolicy^ Bypass^ -NoLogo^ -NonInteractive^ -NoProfile^ -File^ %pshell_script%
powershell.exe %comm_str%
pause
