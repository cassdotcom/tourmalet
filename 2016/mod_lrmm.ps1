function Write-Report
{
    # PARAMETERS
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateSet('Report','Warning','Error')]
        [System.String]
        $reportClass,

        [Parameter()]
        [System.String]
        $reportPath,

        [Parameter()]
        [System.String]
        $reportText
    )

    # Set error flag
    $errorOut = 0

    # Set report class
    Try {
        Switch ($reportClass) {
            'Report' { $reportClass_Short = "RPT" }
            'Warning' { $reportClass_Short = "WRN" }
            'Error' { $reportClass_Short = "ERR" }
        }
    } Catch {
        $errorOut = 3
        Write-Verbose "[ERR]`t($($errorOut))`tFailed to set Report Class"
        break;
    }


    # Create output string
    Try {
        $reportOutput =  "[$(Get-Date -Format "yyyy/MM/dd HH:mm:ss")] ($($reportClass_Short))`t$($reportText)"
    } Catch {
        # error_Write_Report
        $errorOut = 1
        Write-Verbose "[ERR]`t($($errorOut))`tFailed to set output string"
        break;
    }

    # Write to output
    Try {
        $reportOutput | Out-File $reportPath -Append   
    } Catch {
        $errorOut = 2
        Write-Verbose "[ERR]`t($($errorOut))`tFailed to write to output"
        break;
    }
    
    Try {
        if ( $errOut -eq 0 ) {
            Write-Verbose "No errors in execution"
        }
    } Catch {
        $errorOut = 4
        Write-Verbose "[ERR]`t($($errorOut))`tFailed to report 0 errors"
    }

    return $errorOut
}




function Write-Report
{
    # PARAMETERS
    [CmdletBinding()]
    Param(
        [Parameter()]
        [ValidateSet('Report','Warning','Error')]
        [System.String]
        $reportClass,

        [Parameter()]
        [System.String]
        $reportPath,

        [Parameter()]
        [System.String]
        $reportText
    )

    # Set error flag
    $errorOut = 0

    # Set report class
    Try {
        Switch ($reportClass) {
            'Report' { $reportClass_Short = "RPT" }
            'Warning' { $reportClass_Short = "WRN" }
            'Error' { $reportClass_Short = "ERR" }
        }
    } Catch {
        $errorOut = 3
        Write-Verbose "[ERR]`t($($errorOut))`tFailed to set Report Class"
        break;
    }


    # Create output string
    Try {
        $reportOutput =  "[$(Get-Date -Format "yyyy/MM/dd HH:mm:ss")] ($($reportClass_Short))`t$($reportText)"
    } Catch {
        # error_Write_Report
        $errorOut = 1
        Write-Verbose "[ERR]`t($($errorOut))`tFailed to set output string"
        break;
    }

    # Write to output
    Try {
        $reportOutput | Out-File $reportPath -Append   
    } Catch {
        $errorOut = 2
        Write-Verbose "[ERR]`t($($errorOut))`tFailed to write to output"
        break;
    }
    
    Try {
        if ( $errOut -eq 0 ) {
            Write-Verbose "No errors in execution"
        }
    } Catch {
        $errorOut = 4
        Write-Verbose "[ERR]`t($($errorOut))`tFailed to report 0 errors"
    }

    return $errorOut
}




function Test-ModelPath
{

    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.Object]
        $modelObj,
        
        [Parameter()]
        [System.String]
        $reportLog
    )

    $errorOut = 0

    Try {
        if ( ! ( Test-Path $modelObj.PATH ) ) {
            # model not found
            Write-Host "MISSING:`t$($modelObj.MODEL)" -ForegroundColor Red
            $errOut = Write-Report -reportClass Warning -reportPath $reportLog -reportText "MISSING:`t$($modelObj.MODEL)"
            $modelFound = $false
        } else {
            Write-Host "FOUND:`t$($modelObj.MODEL)" -ForegroundColor Green
            $errOut = Write-Report -reportClass Report -reportPath $reportLog -reportText "FOUND:`t$($modelObj.MODEL)"
            $modelFound = $true
        }
    } Catch {
        Write-Host "!--" -ForegroundColor DarkRed -BackgroundColor White
        Write-Host "ERROR: Failed to test $($modelObj.MODEL)"
        $errorOut = 1
        break;
    }#endTRY_CATCH_1

    Write-Output @($errorOut, $modelFound)

}





function Search-ModelFolder
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [System.Object]
        $modelObj,
        
        [Parameter()]
        [System.String]
        $reportLog
    )

    Try {
        if ( ! ( Test-Path -Path $modelObj.FOLDER ) ) {
            
        }
    } Catch {

    }
}





function Parse-ModelPath
{

	Param($modelPath)
	
	Try {	
		$path = $modelPath.Split("\")
		
		$modelGDN = $path[6]
		$modelLDZ = $path[7]
		$modelNetwork = $path[8]
		$modelClass = $path[9]
		$modelName = $path[10]
	} Catch {	
		$modelGDN = "Unknown"
		$modelLDZ = "00"
		$modelNetwork = "NoNet"
		$modelClass = "FY9"
		$modelName = "NoName"
	}
	
	Write-Output @($modelGDN,$modelLDZ,$modelNetwork,$modelClass,$modelName)

}







function Get-ModelNumber 
{

    Param($modelPath)
    
    [regex]$rxNum = '\d{6}'
    
    Try {
    
        $netNum = $rxNum.Match($modelPath).Value
        
    } Catch {
    
        $netNum = "000000"
        
    }
    
    Write-Output $netNum

}
