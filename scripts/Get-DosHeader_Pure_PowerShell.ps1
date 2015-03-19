function Get-DosHeader
{
<#
.SYNOPSIS

    Parses and outputs the DOS header of a PE (portable executable) file on disk.

    Author: Matthew Graeber (@mattifestation)

.PARAMETER FilePath

    Path to the portable executable file on disk.

.INPUTS

    System.IO.FileInfo, System.String[]

    Accepts an array of file path strings as well as the file output from Get-ChildItem.

.OUTPUTS

    PE+_IMAGE_DOS_HEADER

    Returns a fully parsed DOS header.

.EXAMPLE

    C:\PS> Get-ChildItem "$($Env:SystemRoot)\System32\*.dll" | Get-DosHeader

    Description
    -----------
    Returns the DOS headers from all the DLLs in the System32 directory

.EXAMPLE

    C:\PS> Get-DosHeader -FilePath C:\Windows\SysWOW64\calc.exe

.NOTES

    This is a pure PowerShell-based implementation of Get-DosHeader. This was designed to illustrate
    the limitations of using only cmdlets in a script. This script will run in PowerShell in
    'ConstrainedLanguage' mode (i.e. Windows RT).

.LINK

    http://www.exploit-monday.com
#>

    [CmdletBinding()] Param (
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [String[]]
        $FilePath
    )

    BEGIN
    {
        Set-StrictMode -Version 2

        $FormatPath = Join-Path $PWD Get-DosHeader.format.ps1xml
        # Don't load format ps1xml if it doesn't live in the same folder as this script
        if (Test-Path $FormatPath)
        {
            Update-FormatData -PrependPath $FormatPath -ErrorAction SilentlyContinue
        }

        # Define constant variables
        # This will be used on the e_magic field. Realistically, you will only see 'DOS_SIGNATURE'
        New-Variable -Option Constant -Name IMAGE_DOS_SIGNATURE -Value @{
            ([UInt16] 23117)='DOS_SIGNATURE'
            ([UInt16] 17742)='OS2_SIGNATURE'
            ([UInt16] 17740)='VXD_SIGNATURE'
            }

        New-Variable -Option Constant -Name DosHeaderSize -Value 64

        function Local:ConvertTo-Int
        {
            Param
            (
                [Parameter(Position = 1, Mandatory = $True)]
                [Byte[]]
                $ByteArray
            )

            switch ($ByteArray.Length)
            {
                # Only convert words and dwords
                2 { Write-Output ( [UInt16] ('0x{0}' -f (($ByteArray | % {$_.ToString('X2')}) -join '')) ) }
                4 { Write-Output (  [Int32] ('0x{0}' -f (($ByteArray | % {$_.ToString('X2')}) -join '')) ) }
            }
        }
    }

    PROCESS
    {
        # If user provided a relative path, convert it to an absolute path
        $FullPath = Resolve-Path $FilePath

        # Read in just enough bytes to capture the DOS header. We don't care about the remainder of the file
        [Byte[]] $FileByteArray = Get-Content $FullPath -Encoding Byte -TotalCount $DosHeaderSize

        if ( $FileByteArray.Length -lt $DosHeaderSize )
        {
            # You're likely not dealing with a PE file in this case
            Write-Verbose "$($FullPath) is not large enough to contain a full DOS header."

            return
        }

        # Process the e_res field array. Recall, e_res is an array of four WORDs
        $e_resTemp = $FileByteArray[28..35]
        $e_res = New-Object UInt16[](4)

        foreach ($i in 0..3)
        {
            $high = $i * 2 + 1
            $low = $i * 2
            $e_res[$i] = ConvertTo-Int $e_resTemp[$high..$low]
        }

        # Process the e_res2 field array. Recall, e_res2 is an array of ten WORDs
        $e_res2Temp = $FileByteArray[40..59]
        $e_res2 = New-Object UInt16[](10)

        foreach ($i in 0..9)
        {
            $high = $i * 2 + 1
            $low = $i * 2
            $e_res2[$i] = ConvertTo-Int $e_res2Temp[$high..$low]
        }

        $DosHeaderFields = @{
            e_magic =    $IMAGE_DOS_SIGNATURE[(ConvertTo-Int $FileByteArray[1..0])]
            # Note the reverse array offset notation being used to convert little-endian fields
            # The reversed bytes are then converted to their respective type using the ConvertTo-Int helper function
            e_cblp =     ConvertTo-Int $FileByteArray[3..2]
            e_cp =       ConvertTo-Int $FileByteArray[5..4]
            e_crlc =     ConvertTo-Int $FileByteArray[7..6]
            e_cparhdr =  ConvertTo-Int $FileByteArray[9..8]
            e_minalloc = ConvertTo-Int $FileByteArray[11..10]
            e_maxalloc = ConvertTo-Int $FileByteArray[13..12]
            e_ss =       ConvertTo-Int $FileByteArray[15..14]
            e_sp =       ConvertTo-Int $FileByteArray[17..16]
            e_csum =     ConvertTo-Int $FileByteArray[19..18]
            e_ip =       ConvertTo-Int $FileByteArray[21..20]
            e_cs =       ConvertTo-Int $FileByteArray[23..22]
            e_lfarlc =   ConvertTo-Int $FileByteArray[25..24]
            e_ovno =     ConvertTo-Int $FileByteArray[27..26]
            e_res =      $e_res
            e_oemid =    ConvertTo-Int $FileByteArray[37..36]
            e_oeminfo =  ConvertTo-Int $FileByteArray[39..38]
            e_res2 =     $e_res2
            e_lfanew =   ConvertTo-Int $FileByteArray[63..60]
        }

        # Create the custom object
        $DosHeader = New-Object PSObject -Property $DosHeaderFields

        # Apply the 'PEHeader.DosHeader' type name to the custom object so that it can be formatted properly with our ps1xml file
        $DosHeader.PSObject.TypeNames[0] = 'PEHeader.DosHeader'

        # Add file info to the custom object as an additional member. This will provide context to the DOS header for when
        # we perform statistaical analysis of a large set of DOS headers
        $DosHeader = Add-Member -InputObject $DosHeader -Name 'FileInfo' -Value (Get-ChildItem $FullPath) -MemberType NoteProperty -PassThru

        # if e_magic is not defined in IMAGE_DOS_SIGNATURE, then it is an invalid DOS header.
        if (-not $IMAGE_DOS_SIGNATURE.ContainsValue($DosHeader.e_magic))
        {
            Write-Verbose "$($FullPath) has in invalid DOS header."
        }
        else
        {
            Write-Output $DosHeader
        }
    }

    END {}
}