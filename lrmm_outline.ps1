<#	------------------------------------------------------------------------
	FILE NAME: asp_outline.ps1
	PARAMETERS: None
	
	AVERAGE SYSTEM PRESSURE: DISABLE SUBSYSTEMS
		Takes exchange file from Synergee with identified subsystems
		Finds all plastic subsystems
		Sets service state of pipes in all plastic subsystems to 'Disabled'
		Modifies exchange file.
 
 
	For logging purposes:
                [#] - indicates model name
                [@] - indicates model filepath
                [8] - indicates subsystem
                [~] - indicates ASP 
	
	------------------------------------------------------------------------#>
	
<# 
	USE THIS AREA TO DECLARE ANY CONSTANTS NOT IN SETTINGS FILE ETC...
																										#>
# FAILSAFE ERROR HANDLING
# If script / transcript fails, this file will still catch it.
# Saves in local directory - ie where this script is saved
$ERROR_LOG = 'catch_errors.txt'

# GET DATE AND TIMES
$TIMES = Get-Date -format yyyy-mm-dd_hh-mm-ss
$SLEEP_FOR = $h.Get_Item("sleep_for")




<#------------------------------------------------------------------------------------------------------->
 
	FIND SETTINGS FILE
		Try to make this the same file that Synergee uses, to cut down on files.
		
<-------------------------------------------------------------------------------------------------------#>


# Path to where .ini file lives -- BUT NOT THE PATH TO THE INI FILE ITSELF!!!!!
$SETTINGS_PATH = 'S:\TEST AREA\ac00418\settings\'
$SETTINGS_FILE = 'asp_settings.ini'
$ASP_SCRIPT_SETTINGS = $SETTINGS_PATH + $SETTINGS_FILE

# Load file - if this doesn't work, quit script
if(!(Test-Path $ASP_SCRIPT_SETTINGS)){write-host "ERROR Settings file not loaded" > $ERROR_LOG;return}

# Get settings - if try fails, catch and report error to default $ERROR_LOG
Try {
                # FileNotFound Exception will not cause PShell failure so explicitly state
                $ErrorActionPreference = "Stop"
                # Get settings content - there is some cleverness here to cope with ini format ( [ModelName] etc..)
                Get-Content $ASP_SCRIPT_SETTINGS | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
                # Does data exist?
                if ($?){ } # continue
                else { throw $error[0].exception}
	}
Catch 	{
                Start-Transcript -path $ERROR_LOG
                write-host " "
                write-host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                write-host " "
                write-host "ERROR: Settings file not loaded."
                write-host "File should be asp_settings.ini"
                write-host " "
                write-host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                write-host " "
                Stop-Transcript
                return
		}
Finally {
				# Resets Error preference, otherwise script will quit if model not found and other such exceptions caught.
                $ErrorActionPreference = "Continue"
		}
		
		
		
		
<#------------------------------------------------------------------------------------------------------->
 
	LOAD SETTINGS FILE
		Try to make this the same file that Synergee uses, to cut down on files.
		
<-------------------------------------------------------------------------------------------------------#>
 
# Initiate the log for recording our script today
$SCRIPT_LOG = $($h.Get_Item("script_log") + "_$TIMES.log")
Start-Transcript -path $SCRIPT_LOG -append
write-host "For logging purposes:"
write-host "        [#] - indicates model name"
write-host "        [@] - indicates model filepath"
write-host "        [8] - indicates subsystem"
write-host "        [~] - indicates ASP"
 
# Get script details
$CODE_VERSION = $h.Get_Item("code_&_version")
$NUMBER_OF_MODELS = $h.Get_Item("number_of_models")
$OUTPUT_PATH = $h.Get_Item("output_path")
$RESULTS = $($OUTPUT_PATH + "ASP_Results.csv")
write-host " "
write-host "BEGIN SCRIPT @ $TIMES"
write-host " "
write-host "======================================================================"
write-host "======================================================================"
write-host "$CODE_VERSION"
write-host " "
write-host "There are $number_of_models models to be processed"
 
 
if ($NUMBER_OF_MODELS -lt 1){
                write-host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                write-host " "
                write-host "ZERO MODELS IN SETTINGS FILE"
                write-host "STOPPING SCRIPT"
                return}
else{
                # Create output table
                $results_table_out = @()
 
                for ($m = 1; $m -le $NUMBER_OF_MODELS; $m++)
                {
                                # Create results table for all models
                                $results_table = New-Object PSObject
                                # Each subsystem summary is piped to this array:
                                $summary_table_out = @()
                                # Get title from settings file
                                $TITLE = $h.Get_Item("ModelName$m")
                                # Get model name
								#
								#
								# TO BE ADDRESSED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                                $MODEL_NAME = "S:\XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
								#
								#
								#
                                # Get model exchange  file
                                $PIPE_LIST_IN = $($TITLE + "_asp.csv")
                                # Create output exchange file name
                                $PIPE_LIST_OUT = $($OUTPUT_PATH + $TITLE + "_OUT.csv")
                                # To count the number of all PE systems
                                $all_PE_count = 0
                               
                               
                                write-host "[#] $m. Processing $MODEL_NAME"             
                                # read contents to table: 'PipeID','Name','Average Pressure','Material','Service State','Symbol Name','Result Subsystem ID'
                                write-host "[@] Opening CSV: $PIPE_LIST_IN............" -NoNewLine
                                try {
                                                $ErrorActionPreference = "Stop"
                                                $pipe_list = Import-Csv $PIPE_LIST_IN -Header 'PipeID','Name','Average Pressure','Material','Service State','Symbol Name','Result Subsystem ID'
                                                if ($?) { }
                                                else { throw $error[0].exception}}
                                catch { # import-csv failed
                                                write-host "ERROR: IMPORT-CSV FAILED"
                                                write-host "ATTEMPTED: $PIPE_LIST_IN"
                                                return}
                                finally { $ErrorActionPreference = "Continue" }
                               
                                # Need to throw away Synergee added headers and footers from file
                                $pipe_list = $pipe_list[3 .. ($pipe_list.count - 7)]
                               
                                # How many pipes in model?
                                $number_of_pipes = $pipe_list.count
                                write-host "DONE"
                                write-host "-----There are $number_of_pipes pipes in model"
 
 
                                # find number of subsystems
                                if(($unique_subsystems = ($pipe_list | Group -property 'Result Subsystem ID').length) -lt 1){$unique_subsystems = 1}
                                write-host "-----There are $unique_subsystems subsystems"
                                write-host " "
 
 
                                # for each subsystem, find how big the set "NOT PE" is
                                #             if 0 == all PE, so disable STATE
                                #             else == mixed, so 'MAYBE ADD A LETTER TO START OF PIPE????"
                                for ($i = 1;$i -le $unique_subsystems; $i++)
                                {                                             
                                                $summary_table = New-Object PSObject
                                                write-host "[8] Evaluating Subsystem $i............" -NoNewLine
                                                # Gather set of subsystem pipes
                                                $pipe_subsystem = $pipe_list|Where-Object {$_.'Result Subsystem ID' -like "$i"}
                                                # Count number of non-PE pipes in this set
                                                $not_PE = ($pipe_subsystem|Where-Object {$_.Material -ne "PE"}).Count
                                                # start-sleep $SLEEP_FOR
                                                write-host "DONE"
													
                                                # if count = 0, all PE
                                                if ($not_PE -lt 1)
                                                {
                                                                write-host "[8] There are 0 non-PE pipes in Subsystem $i"
                                                                write-host "-----Disabling Subsystem $i pipes............" -NoNewLine
                                                                write-host "DONE"
                                                                write-host " "
                                                                # For each pipe in subsystem change service state
                                                                $pipe_list|Where-Object {$_.'Result Subsystem ID' -like "$i"}|ForEach-Object{
                                                                                $_.'Service State' = "Disabled"} 
                                                                $asp_sub = 0
                                                                $mains_state = "Disabled"
                                                                # Increment all PE counter
                                                                $all_PE_count++
                                                }
                                                else
                                                {
                                                                write-host "[8] There are $not_PE non-PE pipes in Subsystem $i"
                                                                write-host " "
                                                                $asp_sub = ($pipe_subsystem|Measure-Object 'Average Pressure' -Average).Average
                                                                $mains_state = "Enabled"
                                                }
                                               
                                                $summary_table | Add-Member NoteProperty State $mains_state
                                                $summary_table | Add-Member NoteProperty NoOfMains $pipe_subsystem.count
                                                $summary_table | Add-Member NoteProperty ASP $asp_sub
                                               
                                                $summary_table_out += $summary_table
                                }
                                # Write subsystem table to file
                                Write-Output $summary_table_out | Export-CSV $($OUTPUT_PATH + $TITLE + "_ASP_Subsystems.csv") -NoType
                               
                               
                                # Calculate average system pressure of enabled pipes for all model
                                $mixed_subsystems = $pipe_list|Where-Object {$_.'Service State' -like "Enabled"}
                                $mixed_subsystems_mains = $mixed_subsystems.count
                                write-host "[~] There are $mixed_subsystems_mains mixed subsystem mains"
                                $asp = ($mixed_subsystems|Measure-Object 'Average Pressure' -Average).Average
                                write-host "[~] Average System Pressure is $asp"
                               
                               
                                # Write model to results table
                                $results_table | Add-Member NoteProperty ID $m
                                $results_table | Add-Member NoteProperty Title $TITLE
                                $results_table | Add-Member NoteProperty TotalSubsystems $unique_subsystems
                                $results_table | Add-Member NoteProperty AllPESubsystems $all_PE_count
                                $results_table | Add-Member NoteProperty LRMMsubsystems ($unique_subsystems - $all_PE_count)
                                $results_table | Add-Member NoteProperty ASP $asp
                               
                                $results_table_out += $results_table    
                               
 
                                # Export to CSV
                                write-host "[@] Exporting $PIPE_LIST_OUT............" -NoNewLine
                                $pipe_list| Export-CSV $PIPE_LIST_OUT -NoType
                                write-host "DONE"
                                write-host " "
                                write-host "-----------------------------------------------------------------------"
                                write-host " "
                }
 
                Write-Output $results_table_out | Export-CSV $($OUTPUT_PATH + "LRMM_ASP_Subsystems.csv") -NoType
                write-host "======================================================================"
                write-host "======================================================================"
                write-host " "
}
write-host "END SCRIPT @ $TIMES"
stop-transcript


# # # # # # # # # # # # # # # # function fileNotFoundError([string]$fileNotFound, [string]$ERROR_LOG)
# # # # # # # # # # # # # # # # {
                # # # # # # # # # # # # # # # # Start-Transcript -path $ERROR_LOG -append
                # # # # # # # # # # # # # # # # write-host " "
                # # # # # # # # # # # # # # # # write-host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                # # # # # # # # # # # # # # # # write-host " "
                # # # # # # # # # # # # # # # # write-host "ERROR: file not found."
                # # # # # # # # # # # # # # # # write-host "$fileNotFound"
                # # # # # # # # # # # # # # # # write-host " "
                # # # # # # # # # # # # # # # # write-host "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
                # # # # # # # # # # # # # # # # write-host " "
                # # # # # # # # # # # # # # # # Stop-Transcript
# # # # # # # # # # # # # # # # }