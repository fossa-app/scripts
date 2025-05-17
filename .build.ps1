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

    $generatorId = Get-Random -Maximum 1024

    $userEnvironmentVariables = @{
        'DOTNET_ENVIRONMENT'         = $environmentName
        'ASPNETCORE_ENVIRONMENT'     = $environmentName
        'ConnectionStrings__MongoDB' = $connectionString
        'GeneratorId'                = $generatorId
        'DD_API_KEY'                 = $datadogApiKey
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
    Exec { docker compose up --detach --wait $Services }
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
