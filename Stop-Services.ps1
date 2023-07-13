$ErrorActionPreference = 'Stop'

docker compose down

$dockerVolumes = docker volume ls --format json | ConvertFrom-Json -Depth 100

foreach ($dockerVolume in $dockerVolumes) {
    $dockerVolumeName = $dockerVolume.Name

    docker volume rm $dockerVolumeName
}
