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
function Comment-Xml-Node(){
<# 
.Synopsis
  Comments Out an XML node
.Description
  Comments Out an XML node
.Parameter FilePath

.Parameter NodeXPath
    XPath query to selct the node which should be commented out
.Example
   # Comment out the config sections XML node in a web.config.
   Comment-Xml-Node -FilePath "c:\Path\to\web.config" -NodeXPath "//configuration/configSections"
#>
	[CmdletBinding()] 
    param (
	    [Parameter(Mandatory = $true)]
        [string]$FilePath, 
		[Parameter(Mandatory = $true)]
		[string]$NodeXPath #
    )
    Begin 
        {
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Function started"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: Parameters: $($MyInvocation.MyCommand.ParameterSets)"
        Write-Verbose "$($MyInvocation.MyCommand.Name):: FilePath = $FilePath, NodeXPath =$NodeXPath"
        } 
	Process 
        {
			[xml]$xml = Get-Content -Path "$FilePath"

			# Find the nodes that we want to comment
			$xml.SelectNodes("$NodeXPath") | ForEach-Object {

				$nodeToComment = $_;
				$xmlComment = $xml.CreateComment($nodeToComment.OuterXml);

				# Comment the node
				$nodeToComment.ParentNode.ReplaceChild($xmlComment, $nodeToComment);
			}
			# Save the file
			$xml.Save("$FilePath");
		}
	 End 
        {Write-Verbose "$($MyInvocation.MyCommand.Name):: Function ended"}
}
