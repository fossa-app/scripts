[CmdletBinding()]
param (
    [Parameter()]
    [bool]
    $Pull,
    [Parameter()]
    [string[]]
    $Services
)

Set-StrictMode -Version Latest

task CreateDotEnv -If { -not (Test-Path -Path '.env') } {
    $keybaseUserName = Exec { keybase whoami }
    $environmentUserName = $keybaseUserName -replace '[^a-zA-Z]', ''

    $environmentName = "$environmentUserName-Local-Development".ToUpperInvariant()

    $connectionString = Get-Secret -Name 'FossaApp-ConnectionString' -AsPlainText
    $datadogApiKey = Get-Secret -Name 'FossaApp-DatadogApiKey' -AsPlainText
    $honeycombApiKey = Get-Secret -Name 'FossaApp-HoneycombApiKey' -AsPlainText

    $generatorId = Get-Random -Maximum 1024

    $userEnvironmentVariables = @{
        'DOTNET_ENVIRONMENT'         = $environmentName
        'ASPNETCORE_ENVIRONMENT'     = $environmentName
        'ConnectionStrings__MongoDB' = $connectionString
        'GeneratorId'                = $generatorId
        'DD_API_KEY'                 = $datadogApiKey
        'HONEYCOMB_API_KEY'          = $honeycombApiKey
        'HONEYCOMB_DATASET'          = 'FossaApp-Local'
    }

    $userEnvironmentVariables.GetEnumerator()
    | Sort-Object -Property Key
    | ForEach-Object {
        "$($_.Key)=$($_.Value)"
    }
    | Out-File -FilePath '.env' -Force
}

task Pull -If $Pull CreateDotEnv, {
    Exec { docker compose pull }
}

task Start CreateDotEnv, Pull, {
    try {
        Exec { docker compose up --detach --wait $Services }
    }
    catch {
        $containerIds = & docker compose ps --all -q 2>$null

        if (-not $containerIds) {
            throw $_
        }

        $nonZero = @()
        foreach ($id in $containerIds) {
            $info = & docker inspect -f '{{.Name}} {{.State.ExitCode}}' $id 2>$null
            if (-not $info) { continue }
            $parts = $info -split '\s+'
            $name = ($parts[0] -replace '^/', '')
            $code = 0
            if ($parts.Length -gt 1) { [int]::TryParse($parts[1], [ref]$code) | Out-Null }
            if ($code -ne 0) { $nonZero += "$name ($code)" }
        }

        if ($nonZero.Count -gt 0) {
            Write-Error "Found containers with non-zero exit codes: $($nonZero -join ', ')"
            throw $_
        }
    }
}

task Stop {
    Exec { docker compose down --volumes }
}

task RemoveVolumes Stop, {
    foreach ($dockerVolume in $dockerVolumes) {
        $dockerVolumeName = $dockerVolume.Name

        docker volume rm $dockerVolumeName
    }
}
