Stop-NAVServerInstance -ServerInstance Nav -Verbose

# Ejecutar en el powershell del contenedor


Start-NAVServerInstance -ServerInstance Nav -Verbose

#Para crear el usuario

New-NAVServerUser Nav -WindowsAccount smorales
New-NAVServerUserPermissionSet Nav -WindowsAccount smorales -PermissionSetId SUPER

New-NAVServerUser BC -UserName dzafon -Password (ConvertTo-SecureString 'Dzafon1' -AsPlainText -Force)
New-NAVServerUserPermissionSet BC -UserName dzafon -PermissionSetId SUPER