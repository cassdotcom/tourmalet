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

    This implementation of Get-DosHeader defines the enumeration and struct of the DOS header with C# code.
    This method is ideal for clearly illustrating the layout of the DOS header. It is also less tricky to
    implement over a reflection-based solution. This does however leave a greater forensic footprint by
    calling csc.exe and writing temporary files to disk during compilation.

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
        if (-not ('PE' -as [Type]))
        {
            $DOSHeaderDefinition = @'
                using System;
                using System.Runtime.InteropServices;
  
                public class PE
                {
                    public enum IMAGE_DOS_SIGNATURE : ushort
                    {
                        DOS_SIGNATURE =    0x5A4D,      // MZ
                        OS2_SIGNATURE =    0x454E,      // NE
                        VXD_SIGNATURE =    0x454C,      // LE
                    }

                    [StructLayout(LayoutKind.Sequential, Pack=1)]
                    public struct _IMAGE_DOS_HEADER
                    {
                        public IMAGE_DOS_SIGNATURE e_magic;        // Magic number
                        public ushort              e_cblp;         // public bytes on last page of file
                        public ushort              e_cp;           // Pages in file
                        public ushort              e_crlc;         // Relocations
                        public ushort              e_cparhdr;      // Size of header in paragraphs
                        public ushort              e_minalloc;     // Minimum extra paragraphs needed
                        public ushort              e_maxalloc;     // Maximum extra paragraphs needed
                        public ushort              e_ss;           // Initial (relative) SS value
                        public ushort              e_sp;           // Initial SP value
                        public ushort              e_csum;         // Checksum
                        public ushort              e_ip;           // Initial IP value
                        public ushort              e_cs;           // Initial (relative) CS value
                        public ushort              e_lfarlc;       // File address of relocation table
                        public ushort              e_ovno;         // Overlay number
                        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 4)]
                        public ushort[]            e_res;          // May contain 'Detours!' if detoured in memory
                        public ushort              e_oemid;        // OEM identifier (for e_oeminfo)
                        public ushort              e_oeminfo;      // OEM information; e_oemid specific
                        [MarshalAsAttribute(UnmanagedType.ByValArray, SizeConst=10)]
                        public ushort[]            e_res2;         // Reserved public ushorts
                        public int                 e_lfanew;       // Offset to PE header (_IMAGE_NT_HEADERS)
                    }
                }
'@
            Add-Type -TypeDefinition $DOSHeaderDefinition -WarningAction SilentlyContinue | Out-Null

        }

        # Get the size of the defined DOS header structure.
        # Note: it should be 64 bytes. This can be validated in windbg with the following command:
        # `dt -v ntdll!_IMAGE_DOS_HEADER` or `?? sizeof(ntdll!_IMAGE_DOS_HEADER)`
        New-Variable -Option Constant -Name DosHeaderSize -Value ([System.Runtime.InteropServices.Marshal]::SizeOf([PE+_IMAGE_DOS_HEADER]))
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
        $DosHeader = [System.Runtime.InteropServices.Marshal]::PtrToStructure($DOSHeaderAddress, [PE+_IMAGE_DOS_HEADER])

        # Apply the 'PEHeader.DosHeader' type name to the custom object so that it can be formatted properly with our ps1xml file
        $DosHeader.PSObject.TypeNames[0] = 'PEHeader.DosHeader'

        # Add file info to the custom object as an additional member. This will provide context to the DOS header for when
        # we perform statistaical analysis of a large set of DOS headers
        $DosHeader = Add-Member -InputObject $DosHeader -Name 'FileInfo' -Value (Get-ChildItem $FullPath) -MemberType NoteProperty -PassThru

        # Free the unmanaged memory that was allocated.
        $Handle.Free()

        # if e_magic is not defined in IMAGE_DOS_SIGNATURE, then it is an invalid DOS header.
        if (-not [Enum]::IsDefined([PE+IMAGE_DOS_SIGNATURE], $DosHeader.e_magic))
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