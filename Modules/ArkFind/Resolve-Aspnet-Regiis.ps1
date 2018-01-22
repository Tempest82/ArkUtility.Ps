#   Copyright (c) 2018 Sean Jordan
#   
#   Permission is hereby granted, free of charge, to any person obtaining a copy
#   of this software and associated documentation files (the "Software"), to deal
#   in the Software without restriction, including without limitation the rights
#   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#   copies of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#   
#   The above copyright notice and this permission notice shall be included in all
#   copies or substantial portions of the Software.
#   
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#   SOFTWARE.
#
###################################################################################
#	Author: Sean Jordan
#   Restrictions: See Copyright and MIT License notice above.
#	
#	Load Module:
#      Save file under a valid modules folder (check $env:PSModulePath for valid locations)
#      e.g. %SystemRoot%\users\<user>\Documents\WindowsPowerShell\Modules\<moduleName>
#      
#      Import-Module ArkFind
#
#	History:
#		- Initial Release (Sean Jordan)
###################################################################################
function Resolve-Aspnet-Regiis(){
<# 
.Synopsis
  returns the location of aspnet_regiis.exe

 .Description
  Determine the location of aspnet_regiis.exe for use in IIS or encryption container operations.

 .Example
   # Return a string of the path if found for aspnet_regiis.exe.
   Resolve-Aspnet-Regiis -NetVersion "4" 

 .Example
   # Return a string of the path if found for aspnet_regiis.exe. with verbose logging
   Resolve-Aspnet-Regiis -NetVersion "4" -Verbose
#>
    [CmdletBinding()] 
    param (
		[Parameter(Mandatory = $false)]
        [string]$NetVersion
    )
    Begin 
        {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Parameters: $($MyInvocation.MyCommand.ParameterSets)"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: NetVersion = $NetVersion"
        } 

    Process 
        {
            $filename = 'aspnet_regiis.exe'
			
            if(-Not $NetVersion -or $NetVersion.StartsWith('4'))
			{
				$RegiisPath = "$env:windir\Microsoft.NET\Framework\v4.0.30319\$filename" # 32bit .Net 4
				if(Test-Path $RegiisPath){ 
                    Write-Verbose "$($MyInvocation.MyCommand.Name)::Found $RegiisPath"
                    return $RegiisPath
                }
				$RegiisPath = "$env:windir\Microsoft.NET\Framework64\v4.0.30319\$filename" # 64bit .Net 4
				if(Test-Path $RegiisPath){ 
                    Write-Verbose "$($MyInvocation.MyCommand.Name)::Found $RegiisPath"
                    return $RegiisPath
                }
			}
			if(-Not $NetVersion -or $NetVersion.StartsWith('2') -or $NetVersion.StartsWith('3'))
			{
				$RegiisPath = "$env:windir\Microsoft.NET\Framework\v2.0.50727\$filename" # 32bit .Net 2-3.5
				if(Test-Path $RegiisPath){ 
                    Write-Verbose "$($MyInvocation.MyCommand.Name)::Found $RegiisPath"
                    return $RegiisPath
                }
				$RegiisPath = "$env:windir\Microsoft.NET\Framework64\v2.0.50727\$filename" # 64bit .Net 2-3.5
				if(Test-Path $RegiisPath){ 
                    Write-Verbose "$($MyInvocation.MyCommand.Name)::Found $RegiisPath"
                    return $RegiisPath
                }
			}
        } 
    End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}
} 
