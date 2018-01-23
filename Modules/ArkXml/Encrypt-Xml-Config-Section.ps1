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
#      Import-Module ArkXml
#
#	History:
#		- Initial Release (Sean Jordan)
###################################################################################
Import-Module -Name "ArkFind"
Import-Module -Name "ArkXml"

function Encrypt-Xml-Config-Section(){
<#
.Synopsis
    Perform Encryption of Web.Config or other XML configuration's sensitive sections
.Description
       
.Parameters
	ConfigFileFullPath, Path to the XML file to transform
	SectionName, Section to act upon
	SectionGroupName - if provided this will be used to aid in locating the specified section
	HasConfigSections - if flagged will comment out ConfigSections. This avoids DLL/Type not found load issues
	MissingRootConfigNode - if flagged will wrap the file in <configuration></configuration>. This allows partial XML files to be modified.
.Example
    Encrypt-Xml-Config-Section -ConfigFileFullPath "d:\content\SampleApplication\web.config" -SectionName "connectionStrings" -HasConfigSections -Verbose
.Reference
	https://msdn.microsoft.com/en-us/library/ff650304.aspx
#>
    [CmdletBinding()] 
    param (
	    [Parameter(Mandatory = $true)]
        [string]$ConfigFileFullPath, # "D:\Content\SampleApp\web.config"
		[Parameter(Mandatory = $true)]
		[string]$SectionName, #
		[Parameter(Mandatory = $false)]
		[string]$SectionGroupName, #
		[Parameter(Mandatory = $false)]
		[switch] $HasConfigSections,
		[Parameter(Mandatory = $false)]
		[switch] $MissingRootConfigNode
    )
    Begin 
        {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Parameters: $($MyInvocation.MyCommand.ParameterSets)"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: ConfigFileFullPath = $ConfigFileFullPath, SectionName =$SectionName, SectionGroupName =$SectionGroupName, HasConfigSections = $HasConfigSections, MissingRootConfigNode = $MissingRootConfigNode"
        } 
	Process 
        {
			if (Test-Path $ConfigFileFullPath) {
				if ($HasConfigSections)
				{ Comment-Xml-Node -FilePath "$ConfigFileFullPath" -NodeXPath "//configuration/configSections"}
				if ($MissingRootConfigNode)
				{ @("<configuration>") + (get-content $ConfigFileFullPath) +  @("</configuration>") | set-content $ConfigFileFullPath }

				$configurationAssembly = "System.Configuration, Version=2.0.0.0, Culture=Neutral, PublicKeyToken=b03f5f7f11d50a3a"
				[void] [Reflection.Assembly]::Load($configurationAssembly)


				$configMap = New-Object -TypeName System.Configuration.ExeConfigurationFileMap
				$configMap.ExeConfigFilename = $ConfigFileFullPath
				$configuration =  [System.Configuration.ConfigurationManager]::OpenMappedExeConfiguration($configMap,0)

				# Unprotect

				$section = $configuration.GetSection($SectionName)
				if (!$section)
				{$sectionGroup = $configuration.GetSectionGroup($sectionGroupName)
				$section = $configuration.GetSection($SectionName)
				}
				if (!$section){throw "Unable to access the Section $Section in $ConfigFileFullPath be sure you have the correct name or pass the section group as well."}
					
				if (-not $section.SectionInformation.IsProtected)
				{
					Write-Verbose "Securing section $section in $ConfigFileFullPath"
					$section.SectionInformation.ProtectSection($dataProtectionProvider);
					$section.SectionInformation.ForceSave = [System.Boolean]::True;
					$configuration.Save([System.Configuration.ConfigurationSaveMode]::Modified);
				}
				else
				{
					Write-Verbose "Section already secure. No change $section in $ConfigFileFullPath"
				}
				#Uncomment, as required
				if ($HasConfigSections){Uncomment-Xml-Node -FilePath "$ConfigFileFullPath" -SearchCriteria "configSections"}
				#Remove configuration root element, as required.
				if ($MissingRootConfigNode) { ((get-content $ConfigFileFullPath).Replace("</configuration>","") | Select-Object -Skip 1 ) | set-content $ConfigFileFullPath}
					}
			else {throw [IO.FileNotFoundException] "File Not Found: Unable to encrypt $ConfigFileFullPath."}
        } 
    End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}
}
