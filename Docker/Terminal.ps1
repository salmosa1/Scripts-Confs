$containerName = "BC-SVAN"
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'es' -select Latest -version 26.5
$auth = 'UserPassword'

$sqlServer     = "demodynamizatic.database.windows.net"
$sqlDb         = "SVAN_250924"
$sqlUser       = "dynamizatic"
$sqlPassword   = "Dyn@m1z@T1C"

# Credenciales de administrador de BC (se solicitarán interactivamente)
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm16092024.' -AsPlainText -Force)

### Comando para crear el contenedor BC
New-BcContainer `
    -accept_eula `
    -accept_outdated `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -assignPremiumPlan `
    -updateHosts `
    -useBestContainerOS `
    -includeTestToolkit `
    -includeAL `
    -EnableTaskScheduler:$false `
    -databaseServer $SqlServer `
    -databaseName $SqlDb `
    -databaseUserName $SqlUser `
    -databasePassword $SqlPassword
