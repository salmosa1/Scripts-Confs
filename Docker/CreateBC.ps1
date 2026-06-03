#UserPassword
$containerName = 'BC'
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm16092024.' -AsPlainText -Force)
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'es' -select Latest -version 28
#Get-BcArtifactUrl -type 'Sandbox' -country 'es' -select NextMinor -accept_insiderEula 
#$LicenseFile = "C:\Users\smorales\Servicios Implantacion DynamizaTIC, S.L\DynamizaTIC Corporativo - 000 - Licencias - Licencias\Dynamizatic\6460864_BC27.bclicense"

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
    #-useSSL true `
    #-installCertificateOnHost `
    #-licenseFile $LicenseFile `

Import-TestToolkitToBcContainer -containerName BC -includePerformanceToolkit -includeTestLibrariesOnly

#Con parametros para redirigir el trafico y poder instalar Docker en una maquina virtual
$containerName = 'BC'
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm16092024.' -AsPlainText -Force)
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'es' -select 'Latest'
$LicenseFile = "C:\Users\smorales\Servicios Implantacion DynamizaTIC, S.L\DynamizaTIC Corporativo - 000 - Licencias - Licencias\Dynamizatic\6460864_BC23.bclicense"
$addParameters = @("-p 8080:8080", "-p 80:80", "-p 7045-7049:7045-7049",  "-p 443:443", "--network=DockerNet")
$addParameters = @("--network=dockernet")

New-BcContainer `
    -accept_eula `
    -accept_outdated `
    -containerName $containerName `
    -credential $credential `
    -auth $auth `
    -artifactUrl $artifactUrl `
    -assignPremiumPlan `
    -licenseFile $LicenseFile `
    -updateHosts `
    -useBestContainerOS `
    -includeTestToolkit `
    -includeTestLibrariesOnly `
    -includeTestFrameworkOnly `
    -additionalParameters $addParameters `
    -includeAL
