$containerName = 'Pronokal'
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm11092015' -AsPlainText -Force)
$auth = 'UserPassword'
$artifactUrl = Get-BcArtifactUrl -type 'Sandbox' -country 'es' -select 'Latest'
$LicenseFile = "C:\Licencia\6831396.bclicense"
#$addParameters = @("-p 8080:8080", "-p 80:80", "-p 7045-7049:7045-7049",  "-p 443:443", "--network=DockerNet")
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
    -additionalParameters $addParameters `
    -includeAL
