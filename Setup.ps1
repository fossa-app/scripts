Install-Module -Name Microsoft.PowerShell.SecretManagement -Force
Install-Module -Name Microsoft.PowerShell.SecretStore -Force
Install-Module -Name SecretManagement.Keybase -Force

if (-not (Get-SecretVault -Name SecretStore -ErrorAction SilentlyContinue)) {
    Register-SecretVault -Name SecretStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
}

if (-not (Get-SecretVault -Name FossaApp -ErrorAction SilentlyContinue)) {
    Register-KeybaseSecretVault -Name FossaApp -Namespace FossaApp -Team fossaapp
}

Install-Module -Name InvokeBuild -Force
