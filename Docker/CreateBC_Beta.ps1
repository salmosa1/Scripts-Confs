#Ver versiones de BC
#Versiones Beta
$sasToken = "?sv=2019-12-12&ss=b&srt=sco&st=2020-09-15T00%3A00%3A00Z&se=2021-04-01T00%3A00%3A00Z&sp=rl&spr=https&sig=9PznJJRE47DoKjlG44Av6ZKtG4MRfh3N6gyFT7RNWSQ%3D"
Get-BCArtifactUrl -storageAccount bcinsider -sasToken $sasToken -select all -country es

#Versiones actuales
Get-BCArtifactUrl -select all -country es

#BC Beta
$sasToken = "?sv=2020-08-04&ss=b&srt=sco&spr=https&st=2022-03-15T00%3A00%3A00Z&se=2022-10-01T00%3A00%3A00Z&sp=rl&sig=4TsLNCqEFYV0xiPbjaasoGsoiKRimVNmYgSYTs9y2pk%3D"
$artifactUrl = Get-BCArtifactUrl -country es -select nextmajor -sasToken $sasToken
$credential = New-Object pscredential 'smorales', (ConvertTo-SecureString -String 'Sm16092024' -AsPlainText -Force)

New-BCContainer -accept_eula `
    -alwaysPull `
    -artifactUrl $artifactUrl `
    -containerName "Botelo" `
    -auth UserPassword `
    -credential $credential `
    -licenseFile "C:\6460864_BC17.flf" `
    -includeAL `
    -updateHosts `
    -assignPremiumPlan `
    -accept_outdated

