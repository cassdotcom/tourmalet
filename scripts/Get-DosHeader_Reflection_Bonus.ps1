function Get-DosHeader
{
<#
.SYNOPSIS

    Parses and outputs the DOS header and 'Rich' signature of a PE (portable executable) file on disk.

    Author: Matthew Graeber (@mattifestation)

.PARAMETER FilePath

    Path to the portable executable file on disk.

.INPUTS

    System.IO.FileInfo, System.String[]

    Accepts an array of file path strings as well as the file output from Get-ChildItem.

.OUTPUTS

    _IMAGE_DOS_HEADER

    Returns a fully parsed DOS header.

.EXAMPLE

    C:\PS> Get-ChildItem "$($Env:SystemRoot)\System32\*.dll" | Get-DosHeader

    Description
    -----------
    Returns the DOS headers from all the DLLs in the System32 directory

.EXAMPLE

    C:\PS> Get-DosHeader -FilePath C:\Windows\SysWOW64\calc.exe

.NOTES

    This implementation of Get-DosHeader defines the enumeration and struct of the DOS header with using
    reflection. This method is by far the most difficult to implement but it outputs actual .NET types
    without leaving the forensic footprints that the C# implementation does. Using reflection to define
    types is ideal for complicated strctures that whose fields are dynamic based on runtime information.

.LINK

    http://www.exploit-monday.com
    http://ntcore.com/files/richsign.htm
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

        # Only define PE type if not already defined
        if (-not ('IMAGE_DOS_SIGNATURE' -as [Type]))
        {
            $DynAssembly = New-Object System.Reflection.AssemblyName('PE')
            $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
            $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('PE', $False)

            $EnumBuilder = $ModuleBuilder.DefineEnum('IMAGE_DOS_SIGNATURE', 'Public', [UInt16])
            # Define values of the enum
            $EnumBuilder.DefineLiteral('DOS_SIGNATURE', [UInt16] 0x5A4D) | Out-Null
            $EnumBuilder.DefineLiteral('OS2_SIGNATURE', [UInt16] 0x454E) | Out-Null
            $EnumBuilder.DefineLiteral('VXD_SIGNATURE', [UInt16] 0x454C) | Out-Null
            $DosSignatureType = $EnumBuilder.CreateType()

            # These are the attributes that a C# struct contain.
            $Attributes = 'AutoLayout, AnsiClass, Class, Public, SequentialLayout, Sealed, BeforeFieldInit'
            # There is no such thing as a DefineStruct type. So define a type with the attributes of a struct.
            # In C#, a struct is essentially a class with no methods.
            $TypeBuilder = $ModuleBuilder.DefineType('_IMAGE_DOS_HEADER', $Attributes, [System.ValueType], 1, 0x40)
            $TypeBuilder.DefineField('e_magic', $DosSignatureType, 'Public') | Out-Null
            $TypeBuilder.DefineField('e_cblp', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_cp', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_crlc', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_cparhdr', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_minalloc', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_maxalloc', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_ss', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_sp', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_csum', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_ip', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_cs', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_lfarlc', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_ovno', [UInt16], 'Public') | Out-Null
            $e_resField = $TypeBuilder.DefineField('e_res', [UInt16[]], 'Public, HasFieldMarshal')

            # Apply the following attribute to e_res: [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
            $ConstructorInfo = [System.Runtime.InteropServices.MarshalAsAttribute].GetConstructors()[0]
            $ConstructorValue = [System.Runtime.InteropServices.UnmanagedType]::ByValArray
            $FieldArray = @([System.Runtime.InteropServices.MarshalAsAttribute].GetField('SizeConst'))
            $AttribBuilder = New-Object System.Reflection.Emit.CustomAttributeBuilder($ConstructorInfo, $ConstructorValue, $FieldArray, @([Int32] 4))
            $e_resField.SetCustomAttribute($AttribBuilder)

            $TypeBuilder.DefineField('e_oemid', [UInt16], 'Public') | Out-Null
            $TypeBuilder.DefineField('e_oeminfo', [UInt16], 'Public') | Out-Null
            $e_res2Field = $TypeBuilder.DefineField('e_res2', [UInt16[]], 'Public, HasFieldMarshal')

            # Apply the following attribute to e_res2: [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst=10)]
            $AttribBuilder = New-Object System.Reflection.Emit.CustomAttributeBuilder($ConstructorInfo, $ConstructorValue, $FieldArray, @([Int32] 10))
            $e_res2Field.SetCustomAttribute($AttribBuilder)

            $TypeBuilder.DefineField('e_lfanew', [Int32], 'Public') | Out-Null

            # Define the new DOS header struct - [_IMAGE_DOS_HEADER]
            $DosHeaderType = $TypeBuilder.CreateType()
        }
        else
        {
            $DosSignatureType = [IMAGE_DOS_SIGNATURE]
            $DosHeaderType = [_IMAGE_DOS_HEADER]
        }

        function Local:ConvertTo-Dword ([Byte[]] $Bytes)
        {
            [UInt32] "0x$(($Bytes[0..3] | % {$_.ToString('X2')}) -join '')"
        }

        function Local:ConvertFrom-Dword ([UInt32] $Dword)
        {
            [Byte[]] (($Dword.ToString('X8').PadLeft(8, '0') -split '([a-f0-9]{2})' | ? {$_}) | % {[Byte]"0x$($_)"})
        }

        # Get the size of the defined DOS header structure.
        # Note: it should be 64 bytes. This can be validated in windbg with the following command:
        # `dt -v ntdll!_IMAGE_DOS_HEADER` or `?? sizeof(ntdll!_IMAGE_DOS_HEADER)`
        New-Variable -Option Constant -Name DosHeaderSize -Value ([System.Runtime.InteropServices.Marshal]::SizeOf($DosHeaderType))
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

        # Acquire a pointer to our byte array. This is necessary since we will be calling PtrToStructure which requires an IntPtr.
        # 'Pin' the byte array so that it can remain at a fixed memory address.
        $Handle = [System.Runtime.InteropServices.GCHandle]::Alloc($FileByteArray, 'Pinned')
        $DOSHeaderAddress = $Handle.AddrOfPinnedObject()

        # Cast the pointer to the byte array as a DOS header structure.
        $DosHeader = [System.Runtime.InteropServices.Marshal]::PtrToStructure($DOSHeaderAddress, $DosHeaderType)

        # Apply the 'PEHeader.DosHeader' type name to the custom object so that it can be formatted properly with our ps1xml file
        $DosHeader.PSObject.TypeNames[0] = 'PEHeader.DosHeader'
        $DosHeader = Add-Member -InputObject $DosHeader -Name 'FileInfo' -Value (Get-ChildItem $FullPath) -MemberType NoteProperty -PassThru

        # if e_magic is not defined in IMAGE_DOS_SIGNATURE, then it is an invalid DOS header.
        if (-not [Enum]::IsDefined($DosSignatureType, $DosHeader.e_magic))
        {
            Write-Verbose "$($FullPath) has in invalid DOS header."
        }
        else
        {
            # Free the unmanaged memory that was allocated.
            $Handle.Free()

            # Calculate the number of bytes of padding between the DOS header and the PE header (if there is any)
            $HeaderPadding = $DosHeader.e_lfanew - $DosHeaderSize

            if ($HeaderPadding -ge 0) # A 'Rich' header likely exists
            {
                # Get all bytes from the beginning of the DOS header to the beginning of the PE header including any padding
                $HeaderBytes = Get-Content $FullPath -Encoding Byte -TotalCount $DosHeader.e_lfanew
            }
            else
            {
                # There is no padding. Only retrieve the DOS header
                $HeaderBytes = Get-Content $FullPath -Encoding Byte -TotalCount $DosHeaderSize

                Write-Verbose "$($FullPath) has no padding after the DOS header."
            }

            # This standard MS-DOS code stub that prints "This program cannot be run in DOS mode."
            # This byte sequence will be used to determine if code stub deviates from the standard.
            $StandardASM = @(0x0E,0x1F,0xBA,0x0E,0x00,0xB4,0x09,0xCD,0x21,0xB8,0x01,0x4C,0xCD,0x21,0x54,0x68,
                             0x69,0x73,0x20,0x70,0x72,0x6F,0x67,0x72,0x61,0x6D,0x20,0x63,0x61,0x6E,0x6E,0x6F,
                             0x74,0x20,0x62,0x65,0x20,0x72,0x75,0x6E,0x20,0x69,0x6E,0x20,0x44,0x4F,0x53,0x20,
                             0x6D,0x6F,0x64,0x65,0x2E,0x0D,0x0D,0x0A,0x24,0x00,0x00,0x00,0x00,0x00,0x00,0x00)


            if ($HeaderPadding -ge $DosHeaderSize)
            {
                # A sixteen-bit MS-DOS code stub exists
                $SixteenBitDosAssembly = $HeaderBytes[$DosHeaderSize..($DosHeaderSize+63)]
            
                if (Compare-Object -ReferenceObject $StandardASM -DifferenceObject $SixteenBitDosAssembly)
                {
                    Write-Warning "$($FullPath) deviates from the normal 16-bit assembly instructions!"
                }
            }

            # Latin encoder that will perform a one-to-one translation of bytes to characters
            # This technique makes finding the offset to 'Rich' easy.
            $Encoder = [Text.Encoding]::GetEncoding(1252)

            if ($Encoder.GetString($HeaderBytes).Contains('Rich'))
            {
                $RichSignaturePresent = $True
            }
            else
            {
                $RichSignaturePresent = $False
            }
        
            # 0x80 is almost always the offset to the beginning of the Rich header. It is not defined to be at this offset though
            # and can vary depending upon the size of the DOS code stub (if a non-standard DOS code stub is present).
            if ($RichSignaturePresent -and (($HeaderPadding - 0x80) -ge 0))
            {
                # The Rich signature is present
                $RichSignatureBytes = $HeaderBytes[0x80..($DosHeader.e_lfanew)]

                # Retrieve the offset to the Rich header XOR key. It is the DWORD that follows 'Rich'
                $XOROffset = $Encoder.GetString($RichSignatureBytes).IndexOf('Rich') + 4
                $RichString = [UInt32] 0x52696368 # 'Rich'

                # The XOR key used to encode the Rich signature
                $XorValue = ConvertTo-Dword $RichSignatureBytes[$XOROffset..($XOROffset+3)]

                $DecryptedRichSignature = New-Object Byte[](0)

                $Offset = 0
                $EntryCount = 0
                # Convert the first field of the Rich header to a DWORD so that it can be XOR'ed
                [UInt32] $Dword = ConvertTo-Dword $RichSignatureBytes[$Offset..($Offset+3)]

                # Unencode the Rich signature one DWORD at a time
                while ($Dword -ne $RichString)
                {
                    $EntryCount++
                    # XOR the current DWORD in the Rich header with the XOR key and convert it back to a byte array
                    $DecryptedRichSignature += [Byte[]] (ConvertFrom-Dword ($Dword -bxor $XorValue))
                    $Offset += 4
                    $Dword = ConvertTo-Dword $RichSignatureBytes[$Offset..($Offset+3)]
                }

                # Validate 'Rich' header. i.e. Starts with 'DanS'
                if (-not $Encoder.GetString($DecryptedRichSignature).Contains('DanS'))
                {
                    Write-Warning "$($FullPath) has an invalid 'Rich' signature!"
                }

                # Total number of entries in the Rich signature
                $EntryCount = ($EntryCount - 4) / 2

                $Offset = 16 # offset to the first Rich signature entry
                $CompilerVersionArray = New-Object PSObject[]($EntryCount)

                # Parse each Rich signature structure
                foreach ($i in 1..$EntryCount)
                {
                    $BuildNumber = [Int32] "0x$(($DecryptedRichSignature[($Offset+1)..$Offset] | % {$_.ToString('X2')}) -join '')"
                    $ProductIdentifier = [Int32] "0x$(($DecryptedRichSignature[($Offset+3)..($Offset+2)] | % {$_.ToString('X2')}) -join '')"
                    $Count = $DecryptedRichSignature[$Offset+4]
                    $Offset += 8

                    $CompilerVersionArray += New-Object PSObject -Property @{ProductIdentifier = $ProductIdentifier; BuildNumber = $BuildNumber; LinkCount = $Count}
                }

                $DosHeader = Add-Member -InputObject $DosHeader -Name 'RichSignature' -Value $CompilerVersionArray -MemberType NoteProperty -PassThru
            }
            else
            {
                # Rich signature is not present
                $DosHeader = Add-Member -InputObject $DosHeader -Name 'RichSignature' -Value $null -MemberType NoteProperty -PassThru
            }

            Write-Output $DosHeader
        }
    }

    END {}
}