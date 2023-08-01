
<#PSScriptInfo

.VERSION 1.0.0

.GUID 34281b0b-eebb-4aa8-83d1-72685b9c550e

.AUTHOR Tigran TIKSN Torosyan

.COMPANYNAME tiksn.com

.COPYRIGHT FossaApp 2023

.TAGS

.LICENSEURI https://github.com/fossa-app/scripts/blob/main/LICENSE

.PROJECTURI https://github.com/fossa-app/scripts/

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

#Requires -Module Microsoft.PowerShell.Management
#Requires -Module SecretManagement.Keybase

<#

.DESCRIPTION
 Set connection string

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [Security.SecureString]
    $Password
)

$plainTextPassword = $Password | ConvertFrom-SecureString -AsPlainText

$plainTextConnectionString = "mongodb+srv://FossaApp:$plainTextPassword@cluster0.8jcoi1w.mongodb.net/FossaApp?retryWrites=true&w=majority"

$secureConnectionString = $plainTextConnectionString | ConvertTo-SecureString -AsPlainText -Force

Set-Secret -Name 'FossaApp-ConnectionString' -Vault 'FossaApp' -SecureStringSecret $secureConnectionString
