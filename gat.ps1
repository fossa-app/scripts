#For PowerShell v3
Function gat {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$list
    )
    $params = ($list | ForEach-Object { [uri]::EscapeDataString($_) }) -join ','
    Invoke-WebRequest -Uri "https://gitattributes.com/api/$params" | Select-Object -ExpandProperty content | Out-File -FilePath $(Join-Path -Path $pwd -ChildPath '.gitattributes') -Encoding ascii
}

gat -list common

Add-Content -Path .\.gitattributes -Value '# Repository Specific' -Encoding ascii
Add-Content -Path .\.gitattributes -Value '*.Dockerfile      text eol=lf' -Encoding ascii
