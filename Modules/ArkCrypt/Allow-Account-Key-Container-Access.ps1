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
#      Import-Module ArkCrypt
#
#	History:
#		- Initial Release (Sean Jordan)
###################################################################################
Import-Module -Name "ArkFind"

function Allow-Account-Key-Container-Access(){
<#
.SYNOPSIS
    Grant account access for encryption operations ( for xml *.config) by providing RSA Container access.
    
.DESCRIPTION
           
.PARAMETER Account
    String of the account name you wish to grant access to

.PARAMETER CredentialContaner
	String of the machine key container you are granting access too.

.EXAMPLE
    Allow-Account-Key-Container-Access -Account "NT AUTHORITY\NETWORK SERVICE" -CredentialContainer "NetFrameworkConfigurationKey" -Verbose

.NOTES

.FUNCTIONALITY
    Designed to easily provide a method to grant access to specified accounts to machine encryption keys for encrypting and decrypting XML config sections

.LINK
	https://msdn.microsoft.com/en-us/library/ff650304.aspx
#>
    [CmdletBinding()] 
    param (
	    [Parameter(Mandatory = $true)]
        [string]$Account, # example "NT AUTHORITY\NETWORK SERVICE"
		[Parameter(Mandatory = $false)]
		[string]$CredentialContainer = "NetFrameworkConfigurationKey"
    )
    Begin 
        {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Parameters: $($MyInvocation.MyCommand.ParameterSets)"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Account = $Account, CredentialContainer =$CredentialContainer"
        } 

    Process 
        {
            $RegiisPath = Resolve-Aspnet-Regiis -NetVersion "4" # Resolve-Aspnet-Regiis function available in Module "ArkFind"
			if ($RegiisPath) { 
                Write-Verbose "Attempting to run  [$RegiisPath -pa $CredentialContainer $Account]"
                $RegiisOutput = & $RegiisPath -pa "$CredentialContainer" "$Account"  2>&1 
				$RegiisOutput | ForEach-Object {Write-Verbose $_.ToString()}
                if ($LASTEXITCODE -ne 0) { throw "Error: Assigning Key container permission for $Account to $CredentialContainer. RC:$LASTEXITCODE" } 

                Write-Verbose "Completed Assigning RSA Key container permission for $Account to $CredentialContainer."
             }
             else{
                Write-Verbose "Cannot locate $RegiisPath to set RSA Key container access"
             }
        } 

    End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}
}
