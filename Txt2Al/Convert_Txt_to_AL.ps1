<#
<#Parámetros configurables (Ver ejemplo)#>

$ServerName = 'SRVNAV' #Se debe poner el docker
$DatabaseName = 'DEV_CAMBA' #Se debe poner el docker
$DatabaseServer = 'SRVSQL'
$TxtPathLocal = 'C:\Temp\cal\querys camba.txt'
$ObjectsToExport = 'Type=Query;Id=50000..50008'
$PathCAL = 'C:\Temp\cal'
$PathAL = 'C:\Temp\al'
=======
<#
$ServerName = '"Nombre del servidor"'
$DatabaseName = '"Nombre de la base de datos"'
$DatabaseServer = '"Base de datos del servidor"'
$TxtPathLocal = '"ruta de un fichero txt donde se exportarán los objetos"'
$ObjectsToExport = 'Type="Tipo de Objeto";Id="Rango de ID"'
$PathCAL = '"Carpeta donde está el txt en CAL"'
$PathAL = '"Carpeta donde se crearán los archivos AL"'

#>

#Parámetros fjios
$User = 'sa'                #Ver si se puede sustituir por el usuario de Windows (Las BBDD se han configurado como dbo para el Grupo Dynamiza en SRVSQL y no va)
$Pass = 'Dyn@m1z@T1C'
$Path = '\\SRVNAV\C$\Temp\AllObjects.txt'
$ModelTools = 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.dll'
$AppsTools = 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.dll'
$AppsManagement = 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Management.dll'
$NavManagement = 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Management.dll'
$ExportModule = 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Ide.psm1'
$Txt2ALPath = 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Txt2Al.exe'

#Copia el txt en local a la ruta del servidor
Copy-Item -Path $TxtPathLocal -Destination $Path

#Entramos en el servidor pasándole los parámetros
Invoke-Command -ComputerName $ServerName -ArgumentList $ModelTools, $AppsTools, $AppsManagement, $NavManagement, $Path, $DatabaseName, $ExportModule, $DatabaseServer, $User, $Pass, $ObjectsToExport -ScriptBlock {
    #Importa módulos para los cmdlets
    Import-Module $args[0], $args[1], $args[2], $args[3], $args[6]
    #Exporta los objetos al txt del servidor
    Export-NAVApplicationObject $args[4] -DatabaseName $args[5] -DatabaseServer $args[7] -Filter $args[10] -Username $args[8] -Password $args[9] -ExportToNewSyntax
}
#Copia el txt del servidor a la ruta en local
Copy-Item -Path $Path -Destination $TxtPathLocal

#Importa módulos para los cmdlets
Import-Module $ModelTools

#Lanza el txt2al en las carpetas indicadas
$Arguments = @("--source=$PathCAL", "--target=$PathAL", "--rename")
Start-Process $Txt2ALPath -ArgumentList $Arguments

