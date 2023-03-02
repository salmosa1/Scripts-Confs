<# Arrancar como administrador #>
start-process powershell –verb runAs

Set-ExecutionPolicy -ExecutionPolicy Unrestricted

<# Instalar modulo navcontainer Obligatorio #>
install-module bccontainerhelper -force
update-module navcontainerhelper -force

<# comandos ver ayuda #>
get-command -Module navcontainerhelper
Get-Help New-NavContainer -full
help new-navcontainer -detailed
Write-NavContainerHelperWelcomeText

<# Visualizar estado de los contenedores #>
docker.exe ps -a

<# Eliminar un container #>
Remove-NavContainer -containerName "SVAN"

<# Iniciar un container #>
docker container start "NAV2018"

<# Parar un container #>
docker container stop "NAV2018"

<# Reiniciar un container #>
docker container restart "NAV2018"

<# Dar permisos para ejecutar comandos de NavContainer sin ejecutar como admin #>
Check-NavContainerHelperPermissions -Fix

<# Copiar un archivo del container a local #>
Copy-FileFromNavContainer `
    -containerName "NAV2018-ES-CU5" `
    -containerPath "C:\Program Files\Microsoft Dynamics NAV\110\Service\CustomSettings.config" `
    -localPath "C:\Temp\CustomSettings.config"

<# Copiar un archivo de local al container #>
Copy-FileToNavContainer `
    -containerName "NAV2018-ES-CU5" `
    -containerPath "C:\Program Files\Microsoft Dynamics NAV\110\Service\CustomSettings.config" `
    -localPath "C:\Temp\CustomSettings.config"

