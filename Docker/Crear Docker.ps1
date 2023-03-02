install-module bccontainerhelper
update-module bccontainerhelper

#Ver versiones de BC
#Versiones Beta
$sasToken = "?sv=2019-12-12&ss=b&srt=sco&st=2020-09-15T00%3A00%3A00Z&se=2021-04-01T00%3A00%3A00Z&sp=rl&spr=https&sig=9PznJJRE47DoKjlG44Av6ZKtG4MRfh3N6gyFT7RNWSQ%3D"
Get-BCArtifactUrl -storageAccount bcinsider -sasToken $sasToken -select all -country es

#Versiones actuales
Get-BCArtifactUrl -select all -country es

#BC Beta
$sasToken = "?sv=2020-08-04&ss=b&srt=sco&spr=https&st=2022-03-15T00%3A00%3A00Z&se=2022-10-01T00%3A00%3A00Z&sp=rl&sig=4TsLNCqEFYV0xiPbjaasoGsoiKRimVNmYgSYTs9y2pk%3D"
$artifactUrl = Get-BCArtifactUrl -country es -select nextmajor -sasToken $sasToken
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm11092015' -AsPlainText -Force)

New-BCContainer -accept_eula `
    -alwaysPull `
    -artifactUrl $artifactUrl `
    -containerName "Botelo" `
    -auth UserPassword `
    -credential $credential `
    -licenseFile "C:\Users\smorales\Servicios Implantacion DynamizaTIC, S.L\DynamizaTIC Corporativo - 000 - Licencias - Licencias\Dynamizatic\6460864_BC17.flf" `
    -includeAL `
    -updateHosts `
    -assignPremiumPlan `
    -accept_outdated

#BC
$artifactUrl = Get-BCArtifactUrl -version 21 -country es -select Latest
#$artifactUrl = Get-BCArtifactUrl OnPrem -version 14 -country es
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm11092015' -AsPlainText -Force)

New-BCContainer -accept_eula `
    -alwaysPull `
    -artifactUrl $artifactUrl `
    -containerName "Demo" `
    -auth UserPassword `
    -credential $credential `
    #-licenseFile "D:\Servicios Implantacion DynamizaTIC, S.L\DynamizaTIC Corporativo - 000 - Licencias - Licencias\Dynamizatic\6460864_BC19.flf" `
    -includeAL `
    -updateHosts `
    -assignPremiumPlan `
    -accept_outdated `
    -useBestContainerOS
    #-includeCSide `
    #-doNotExportObjectsToText `
    #-isolation "hyperv" `

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

<# Docker con Nav 2018 ultimo CU, con autenticación de NavUserPassword, instala el cliente local, apunta contra un SQL externo #>
$navcredential = New-Object System.Management.Automation.PSCredential -argumentList "sa", (ConvertTo-SecureString -String "XxXxXxXxX" -AsPlainText -Force)
New-NavContainer `
    -accept_eula `
    -alwaysPull `
    -imageName "microsoft/dynamics-nav:2018-es" `
    -containerName "NAV2018-ES-CU7" `
    -auth NavUserPassword `
    -includeCSide `
    -updateHosts `
    -enableSymbolLoading `
    -doNotExportObjectsToText `
    -databaseServer "192.168.200.221" `
    -databaseName "Demo Database NAV (11-0)" `
    -databaseCredential $navcredential `
    -licenseFile "C:\6460864-2018.flf"

#BC sin licencia
$containerName = 'demo'
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm11092015' -AsPlainText -Force)
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'es' -select 'Latest'
New-BcContainer `
    -accept_eula `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -imageName 'standardocker' `
    -assignPremiumPlan `
    -dns '8.8.8.8' `
    -usessl `
    -updateHosts