[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Pull,
    [Parameter()]
    [string[]]
    $Services
)

Import-Module -Name InvokeBuild

Invoke-Build -Task Start -Summary -Pull ($Pull.IsPresent) -Services $Services
