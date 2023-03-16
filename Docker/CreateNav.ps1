#Nav 2018 
$artifactUrl = Get-NavArtifactUrl -nav 2018 -cu cu36 -country es
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm11092015' -AsPlainText -Force)

New-NavContainer `
    -accept_eula `
    -accept_outdated `
    -artifactUrl $artifactUrl `
    -containerName Roca `
    -credential $credential `
    -auth UserPassword `
    -licenseFile "C:\Users\smorales\Servicios Implantacion DynamizaTIC, S.L\DynamizaTIC Corporativo - 000 - Licencias - Licencias\Dynamizatic\6460864_2018.flf" `
    -assignPremiumPlan `
    -shortcuts Desktop `
    -enableSymbolLoading `
    -doNotExportObjectsToText `
    -includeCSide `
    -useBestContainerOS `
    -updateHosts