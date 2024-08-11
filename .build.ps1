Set-StrictMode -Version Latest

task CreateDotEnv -If { -not (Test-Path -Path '.env') } {
    $keybaseUserName = Exec { keybase whoami }

    $environmentName = "$keybaseUserName-Local-Development".ToUpperInvariant()

    $connectionString = Get-Secret -Name 'FossaApp-ConnectionString' -AsPlainText

    $userEnvironmentVariables = @{
        'DOTNET_ENVIRONMENT'       = $environmentName
        'ASPNETCORE_ENVIRONMENT'   = $environmentName
        'ConnectionStrings__Mongo' = $connectionString
    }

    $userEnvironmentVariables.GetEnumerator()
    | Sort-Object -Property Key
    | ForEach-Object {
        "$($_.Key)=$($_.Value)"
    }
    | Out-File -FilePath '.env' -Force
}

task Start CreateDotEnv, {
    Exec { docker compose up --detach --wait }
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
