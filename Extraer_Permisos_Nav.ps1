Import-Module 'C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client\Microsoft.Dynamics.Nav.Apps.Tools.psd1'

Export-NAVAppPermissionSet `
    -PermissionSetId 'GEST-COBROS' `
    -ServerInstance 'DynamicsNAV110' `
    -Path '.\Permissions.xml' `
    -Force `
    -Verbose
