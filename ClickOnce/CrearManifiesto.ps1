#Clear-Host
#$defaultValue = 'Dynamics NAV 2018'
#$prompt = Read-Host "Introduce el nombre del cliente/instancia [$($defaultValue)]"
#if (!$prompt -eq "") {$defaultValue = $prompt}

#c:\clickonce\Deployment\ApplicationFiles
#Copiar en c:\clickonce\Deployment\ApplicationFiles RTC files en ApplicationFiles + ClientUserSettings.cfg
#Copiar en c:\clickonce plantilla de OnceClick (DVD NAV)

#compartir para todos la carpeta c:\clickonce

#desde c:\clickonce ejecutar esto
cd Deployment
cd ApplicationFiles
..\..\mage.exe -Update Microsoft.Dynamics.Nav.Client.exe.manifest -FromDirectory .
cd ..
..\mage.exe -update Microsoft.Dynamics.Nav.Client.application -appmanifest ApplicationFiles\Microsoft.Dynamics.Nav.Client.exe.manifest -appcodebase \\h2734293.stratoserver.net\ClickOnce\Deployment\ApplicationFiles\Microsoft.Dynamics.Nav.Client.exe.manifest

#editar fichero c:\clickonce\Deployment\Microsoft.Dynamics.Nav.Client.manifest
#modificar asmv2:product="" y version=""
#modificar ruta codebase="xxxx/ClickOnce\Deployment\Microsoft....
