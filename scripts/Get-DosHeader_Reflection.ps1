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

        # The code that follows is identical to the C# implementation of Get-DosHeader.

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

        # Free the unmanaged memory that was allocated.
        $Handle.Free()

        # if e_magic is not defined in IMAGE_DOS_SIGNATURE, then it is an invalid DOS header.
        if (-not [Enum]::IsDefined($DosSignatureType, $DosHeader.e_magic))
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