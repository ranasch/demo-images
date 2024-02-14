param(
    [Parameter(Mandatory=$false)]
    [boolean] $Packer = ((Get-ChildItem env:packer_* | Measure-Object).Count -gt 0)
)

Get-ChildItem -Path (Join-Path $env:DEVBOX_HOME 'Modules') -Directory | Select-Object -ExpandProperty FullName | ForEach-Object {
	Write-Host ">>> Importing PowerShell Module: $_"
	Import-Module -Name $_
} 

if ($Packer) {
	Write-Host ">>> Register ActiveSetup"
	Register-ActiveSetup  -Path $MyInvocation.MyCommand.Path -Name 'Install-Chocolatey.ps1' -Elevate
} else { 
    Write-Host ">>> Initializing transcript"
    Start-Transcript -Path ([system.io.path]::ChangeExtension($MyInvocation.MyCommand.Path, ".log")) -Append -Force -IncludeInvocationHeader; 
}

$ProgressPreference = 'SilentlyContinue'	# hide any progress output
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ==============================================================================

Invoke-ScriptSection -Title "Installing Choco Package Manager" -ScriptBlock {

	Write-Host ">>> Downloading Chocolatey ..."
	$installer = Invoke-FileDownload -Url 'https://chocolatey.org/install.ps1'

	Write-Host ">>> Installing Chocolatey ..."
	& $installer | Out-Null
}
