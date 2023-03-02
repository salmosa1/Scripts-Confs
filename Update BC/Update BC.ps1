# Tip. Al lanzar las lineas que inicializan las variables, estas se guardan en memoria. Se debe ir lanzando poco a poco con F8. Puedes hacer pequeños bloques controlados
Set-ExecutionPolicy Unrestricted
# Haz un BackUp de las bases de datos.
# Haz una copia de las carpetas de los entornos web.

<# PARTE 1 ################################################################>
# Cambiar los valores de las variables que sean necesarias. 
# Revisar el parametro DatabaseServer de la línea 44.
# Revisar la línea 75

Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\160\Service\"Microsoft.Dynamics.Nav.Model.Tools.dll"
Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\160\Service\"Microsoft.Dynamics.Nav.Apps.Management.dll"
Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\160\Service\"Microsoft.Dynamics.Nav.Management.dll"

$InstanceName = "ENCAMINA"

# Si tienes pensado eliminar el servicio y volver a crearlo, con este comando puedes obtener las configuraciones del servicio que están cambiadas
# Te lo puedes guardar en un txt para luego configurarlo de nuevo correctamente.
Get-NAVServerConfiguration -ServerInstance $InstanceName -IgnoreSettingsWithDefaultValues 

Get-NAVAppInfo -ServerInstance $InstanceName | % { Uninstall-NAVApp -ServerInstance $InstanceName -Name $_.Name -Version $_.Version -Force}
Get-NAVAppInfo -ServerInstance $InstanceName -SymbolsOnly | % { Unpublish-NAVApp -ServerInstance $InstanceName -Name $_.Name -Version $_.Version }

Stop-NAVServerInstance -ServerInstance $InstanceName

<########### FIN PARTE 1 ################################################### #>

# Guardate los accesos de los administration tools y shell de la version vieja.
# Instalar la nueva version de BC. Guardate los accesos a Administration para poder eliminar los servicios antiguos y/o verlos   
# Reiniciar PowerShell para que detecte los cambios. 

<# PARTE 2 ################################################################>
Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\170\Service\"Microsoft.Dynamics.Nav.Model.Tools.dll"
Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\170\Service\"Microsoft.Dynamics.Nav.Apps.Management.dll"
Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\170\Service\"Microsoft.Dynamics.Nav.Management.dll"

$InstanceName = "ENCAMINA"
$OldBCVersion = "16.4.14693.15445"

$WebInstanceName = "ENCAMINA"
$ServerName = "NAV"

$DatabaseName = "ENCAMINA_BC"

$NewBCVersion = "17.2.19367.19735"

$DynamizaLicensePath = "C:\Temp\Extensiones\6460864_BC17.flf"
$CustomerLicensePath = "C:\Temp\Extensiones\7191396.flf"

Invoke-NAVApplicationDatabaseConversion -DatabaseServer $ServerName -DatabaseName $DatabaseName

#Si vas a crear la instancia con el mismo nombre, elimina la antigua y crea la nueva ahora
#Si no, crear el nuevo servicio, y cambiar el valor de InstanceName, darle a F8 en la asignacion para que lo guarde en memoria
Set-NAVServerConfiguration -ServerInstance $InstanceName -KeyName DatabaseName -KeyValue $DatabaseName

Set-NavServerConfiguration -ServerInstance $InstanceName -KeyName "EnableTaskScheduler" -KeyValue false

Restart-NAVServerInstance -ServerInstance $InstanceName

Import-NAVServerLicense -LicenseFile $DynamizaLicensePath -ServerInstance $InstanceName
Restart-NAVServerInstance -ServerInstance $InstanceName

Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\170\AL Development Environment\System.app" -PackageType SymbolsOnly

Sync-NAVTenant -ServerInstance $InstanceName -Mode Sync -Force

#Las dos primeras, han de hacerse de una en una, el resto se pueden hacern en bloque
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\System Application\Source\Microsoft_System Application.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\BaseApp\Source\Microsoft_Base Application.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\Application\Source\Microsoft_Application.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\APIV2\Source\Microsoft__Exclude_APIV2_.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\EssentialBusinessHeadlines\Source\Microsoft_Essential Business Headlines.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\ClientAddIns\Source\Microsoft__Exclude_ClientAddIns_.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\Email - Outlook REST API\Source\Microsoft_Email - Outlook REST API.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\Email - Current User Connector\Source\Microsoft_Email - Current User Connector.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\Email - Microsoft 365 Connector\Source\Microsoft_Email - Microsoft 365 Connector.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\Email - SMTP Connector\Source\Microsoft_Email - SMTP Connector.app"
Publish-NAVApp -ServerInstance $InstanceName -Path "C:\Temp\Update 17.2\bc\Applications\BaseApp\Source\Microsoft_Spanish language (Spain).app"

Sync-NAVTenant -ServerInstance $InstanceName -Mode Sync -Force

Sync-NAVApp -ServerInstance $InstanceName -Name "System Application" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "Base Application" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "Application" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "_Exclude_APIV2_" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "Essential Business Headlines" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "Spanish language (Spain)" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "_Exclude_ClientAddIns_" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "Email - Outlook REST API" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "Email - Current User Connector" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "Email - Microsoft 365 Connector" -Version $NewBCVersion -Force
Sync-NAVApp -ServerInstance $InstanceName -Name "Email - SMTP Connector" -Version $NewBCVersion -Force

Start-NAVAppDataUpgrade -ServerInstance $InstanceName -Name "System Application" -Version $NewBCVersion
Start-NAVAppDataUpgrade -ServerInstance $InstanceName -Name "Base Application" -Version $NewBCVersion
Start-NAVAppDataUpgrade -ServerInstance $InstanceName -Name "Application" -Version $NewBCVersion
Start-NAVAppDataUpgrade -ServerInstance $InstanceName -Name "Spanish language (Spain)" -Version $NewBCVersion
Start-NAVAppDataUpgrade -ServerInstance $InstanceName -Name "Essential Business Headlines" -Version $NewBCVersion
Start-NAVAppDataUpgrade -ServerInstance $InstanceName -Name "_Exclude_ClientAddIns_" -Version $NewBCVersion -Force

Install-NAVApp -ServerInstance $InstanceName -Name "_Exclude_APIV2_" -Version $NewBCVersion
Install-NAVApp -ServerInstance $InstanceName -Name "Email - Outlook REST API" -Version $NewBCVersion -Force
Install-NAVApp -ServerInstance $InstanceName -Name "Email - Current User Connector" -Version $NewBCVersion -Force
Install-NAVApp -ServerInstance $InstanceName -Name "Email - Microsoft 365 Connector" -Version $NewBCVersion -Force
Install-NAVApp -ServerInstance $InstanceName -Name "Email - SMTP Connector" -Version $NewBCVersion -Force

$ServicesAddinsFolder = 'C:\Program Files\Microsoft Dynamics 365 Business Central\170\Service\Add-ins'
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.BusinessChart' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'BusinessChart\Microsoft.Dynamics.Nav.Client.BusinessChart.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.FlowIntegration' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'FlowIntegration\Microsoft.Dynamics.Nav.Client.FlowIntegration.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.OAuthIntegration' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'OAuthIntegration\Microsoft.Dynamics.Nav.Client.OAuthIntegration.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.PageReady' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'PageReady\Microsoft.Dynamics.Nav.Client.PageReady.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.PowerBIManagement' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'PowerBIManagement\Microsoft.Dynamics.Nav.Client.PowerBIManagement.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.RoleCenterSelector' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'RoleCenterSelector\Microsoft.Dynamics.Nav.Client.RoleCenterSelector.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.SatisfactionSurvey' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'SatisfactionSurvey\Microsoft.Dynamics.Nav.Client.SatisfactionSurvey.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.SocialListening' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'SocialListening\Microsoft.Dynamics.Nav.Client.SocialListening.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.VideoPlayer' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'VideoPlayer\Microsoft.Dynamics.Nav.Client.VideoPlayer.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.WebPageViewer' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'WebPageViewer\Microsoft.Dynamics.Nav.Client.WebPageViewer.zip')
Set-NAVAddIn -ServerInstance $InstanceName -AddinName 'Microsoft.Dynamics.Nav.Client.WelcomeWizard' -PublicKeyToken 31bf3856ad364e35 -ResourceFile ($AppName = Join-Path $ServicesAddinsFolder 'WelcomeWizard\Microsoft.Dynamics.Nav.Client.WelcomeWizard.zip')

Import-NAVServerLicense -LicenseFile $CustomerLicensePath -ServerInstance $InstanceName
Restart-NAVServerInstance -ServerInstance $InstanceName

Set-NavServerConfiguration -ServerInstance $InstanceName -KeyName "EnableTaskScheduler" -KeyValue true
Restart-NAVServerInstance -ServerInstance $InstanceName

Set-NAVApplication -ServerInstance $InstanceName -ApplicationVersion $NewBCVersion -Force
Sync-NAVTenant -ServerInstance $InstanceName -Mode Sync -Force
Start-NAVDataUpgrade -ServerInstance $InstanceName -FunctionExecutionMode Serial

<########### FIN PARTE 2 ################################################### #>

<# PARTE 3 ################################################################>

#Hay que esperar hasta que el estado sea operational. Usar el get-navtenant para ver el estado. Despues, reiniciar
Get-NavTenant -ServerInstance $InstanceName

Restart-NAVServerInstance -ServerInstance $InstanceName

#Confirmar que se ha hecho el cambio de version. La version debe coincidier en los dos
Get-NavTenant $InstanceName
Get-NavApplication $InstanceName

#Apaga el IIS, y elimina la carpeta de la instancia web (guardate una copia!)
#A veces instala la version antigua, para asegurarte lanzalo con Administration Shell.
New-NavWebServerInstance -WebServerInstance $WebInstanceName -Server $ServerName -ServerInstance $InstanceName
#Revisar los puertos que ha puesto, que lo suele hacer mal.
#Arrancar el IIS

# Si tiene DocumentCapture, instalar las aplicaciones con el install que hay en la versión correspondiente

#Actualizamos todas nuestras extensiones
Get-NAVAppInfo -ServerInstance $InstanceName | Where-Object {$_.Publisher -like 'DynamizaTIC'} | % { Install-NAVApp -ServerInstance $InstanceName -Name $_.Name -Version $_.Version -Force}
#Despublicamos todas las extensiones de Microsoft de la version antigua
Get-NAVAppInfo -ServerInstance $InstanceName | Where-Object {$_.Publisher -like 'Microsoft' -and $_.Version -eq $OldBCVersion} | % { Unpublish-NAVAp -ServerInstance $InstanceName -Name $_.Name -Version $_.Version}

<########### FIN PARTE 3 ################################################### #>


# Despublicar todas las extensiones antiguas
