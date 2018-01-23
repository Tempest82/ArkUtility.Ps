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

function Uncomment-Xml-Node(){ 
	[CmdletBinding()] 
    param (
	    [Parameter(Mandatory = $true)]
        [string]$FilePath, 
		[Parameter(Mandatory = $true)]
		[string]$SearchCriteria #
    )
    Begin 
        {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Parameters: $($MyInvocation.MyCommand.ParameterSets)"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: FilePath = $FilePath, SearchCriteria =$SearchCriteria"
        } 
	Process 
        {   
			[xml]$xml = Get-Content -Path "$FilePath"

			# Find all comments on the xml file
			$xml.SelectNodes("//comment()") | ForEach-Object {     

				# Convert the comment to an xml node
				$nodeToConvert = $_;  
				[xml]$xmlNode = $nodeToConvert.InnerText | convertto-xml 

				# Find the comment that matches our search criteria
				$xmlNode.SelectNodes("/descendant::*[contains(text(), '$SearchCriteria')]") | ForEach-Object { 

					$nodeToUncomment = $_;

					$seekText = "<!--" + $nodeToUncomment.InnerText + "-->"

					$textReplacement = $nodeToUncomment.InnerText

					# Replace the commented string with uncommented one
					$con = Get-Content "$FilePath"
					$con | % { $_.Replace($seekText, $textReplacement) } | Set-Content "$FilePath"
				}
			}
    }
	 End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}
}
