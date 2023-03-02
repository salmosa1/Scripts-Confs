#------ EJECUTAR EN MODO ADMINISTRADOR EN EL POWERSHELL LOCAL #

$containerPath = "C:\Temp\roca.bak" 
$localPath = "C:\Temp\roca.bak"
docker container stop NAV2018
docker cp  $localPath NAV2018:/$containerPath
docker container start NAV2018
