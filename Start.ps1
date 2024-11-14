[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $Pull
)

Import-Module -Name InvokeBuild

Invoke-Build -Task Start -Summary -Pull ($Pull.IsPresent)
