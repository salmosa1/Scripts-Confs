$ContainerName = 'NAV2018TXT2AL'
$DeltaPath = 'C:\ProgramData\NavContainerHelper\Extensions\Migration\DELTA'

Import-DeltasToNavContainer -containerName $ContainerName -deltaFolder $DeltaPath

Compile-ObjectsInNavContainer -containerName $ContainerName `
    -filter "" `
    -sqlCredential $Credential

$ContainerName = 'NAV2018TXT2AL'
Convert-ModifiedObjectsToAl -containerName $ContainerName -startId 60000 -Verbose -filter "Id=50000..50100"
#Convert-ModifiedObjectsToAl -containerName $ContainerName -startId 60000 -Verbose -filter "Version List=@*CALIDAD*"
#Convert-ModifiedObjectsToAl -containerName $ContainerName -startId 60000 -Verbose -filter "Type=Report"
