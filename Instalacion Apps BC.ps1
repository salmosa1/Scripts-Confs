Function ImportNavModules {
    #Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\210\Service\"Microsoft.Dynamics.Nav.Model.Tools.dll"
    #Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\150\Service\"Microsoft.Dynamics.Nav.Apps.Tools.dll"
    Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\210\Service\"Microsoft.Dynamics.Nav.Apps.Management.dll"
    Import-Module C:\"Program Files"\"Microsoft Dynamics 365 Business Central"\210\Service\"Microsoft.Dynamics.Nav.Management.dll"
}

Function ErrorMessage($MessageNo) {
    switch ($MessageNo) {
        0 { 
            Write-Host "Cancelado" 
            Break "Cancelado"
        }
        1 { 
            Write-Host "La instancia es obligatoria" 
            Break "Cancelado"
        }
        2 {
            Write-Host "La versión antigua es obligatoria" 
            Break "Cancelado"
        }
        3 { 
            Write-Host "El nombre de extension es obligatorio" 
            Break "Cancelado"
        }
        99 { 
            Write-Host "Completado correctamente"
            Read-Host "Presiona Intro para continuar..."
        }
    }     
}

Function Get-FileName($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "APP (*.app)|*.app|License File (*.flf)|*.flf|Todo (*.*)|*.*"
    $OpenFileDialog.ShowDialog() | Out-Null
    if ($OpenFileDialog.FileName -eq "") { ErrorMessage(0) }
    else { return $OpenFileDialog.FileName  }
}

Function Get-Extension {   
    $extensions = Get-NAVAppTableModification -ServerInstance $ServerInstance
    
    for ($x = 0; $x -le $extensions.LongLength - 1; $x++) {
        $version = $extensions[$x].Version.Major.ToString() + '.' + $extensions[$x].Version.Minor.ToString() + '.' + $extensions[$x].Version.Build.ToString() + '.' + $extensions[$x].Version.Revision.ToString()
        $texto = $x.ToString().PadLeft(2, ' ') + ' -- ' + $extensions[$x].Name.ToString().PadRight(35, ' ') + ' Publicador: ' + $extensions[$x].Publisher.ToString().PadRight(20, ' ') + ' Versión: ' + $version.PadRight(20, ' ') + 'AppId: ' + $extensions[$x].AppId.ToString()
        Write-Host $texto
    }
        
    $x = Read-Host "Que extensión?"
    if (!$extensions[$x]) { ErrorMessage(3) }


    return $extensions[$x]
}

Function Get-NavServices {   
    $services = Get-Service -Name "MicrosoftDyn*"
    
    for ($y = 0; $y -le $services.LongLength - 1; $y++) {
        $texto = $y.ToString().PadLeft(2, ' ') + ' -- ' + $services[$y].DisplayName.ToString().PadRight(35, ' ') + ' -- ' + $services[$y].Status.ToString()

        Write-Host $texto
    }
        
    $y = Read-Host "Que servicio?"
    if ($y -gt ($services.LongLength - 1)) { ErrorMessage(1) }

    return $services[$y].ServiceName.Substring($services[$y].ServiceName.LastIndexOf('$') + 1)
}

Function CheckAdminRights {
    ###Run as Admin #########################################################################
    # Get the ID and security principal of the current user account
    $myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
    $myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);

    # Get the security principal for the administrator role
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;

    # Check to see if we are currently running as an administrator
    if ($myWindowsPrincipal.IsInRole($adminRole)) {
        # We are running as an administrator, so change the title and background colour to indicate this
        $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";
        #$Host.UI.RawUI.BackgroundColor = "DarkBlue";
        Clear-Host;
    }
    else {
        # We are not running as an administrator, so relaunch as administrator

        # Create a new process object that starts PowerShell
        $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";

        # Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path
        $newProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"

        # Indicate that the process should be elevated
        $newProcess.Verb = "runas";

        # Start the new process
        [System.Diagnostics.Process]::Start($newProcess);

        # Exit from the current, unelevated, process
        Exit;
    }
}

###Code #################################################################################

CheckAdminRights
ImportNavModules

Do
{
    $Title = "Hola!"
    $Info = "Que deseas hacer?"
    $opt = 2
    $options = [System.Management.Automation.Host.ChoiceDescription[]] @("&Salir", "&Instalar", "&Actualizar", "&Forzar Act.", "&Recreate", "&Despublicar", "R&einstalar", "&Publicar", "Cambiar &Licencia")
    [int]$defaultchoice = 1
    $opt = $host.UI.PromptForChoice($Title , $Info , $Options, $defaultchoice)

    if ($opt -ne 0) {
        $ServerInstance = Get-NavServices
    }

    switch ($opt) {
        1 { #Instalar
            $ExtensionPath = Get-FileName
            $ExtensionName = $ExtensionPath.SubString($ExtensionPath.IndexOfAny("_", $ExtensionPath.LastIndexOf("\")) + 1, $ExtensionPath.LastIndexOf("_") - 1 - $ExtensionPath.IndexOfAny("_", $ExtensionPath.LastIndexOf("\")))

            Write-Host "Instalando..."

            Publish-NAVApp -ServerInstance $ServerInstance -Path $ExtensionPath -SkipVerification -ErrorAction Inquire
            Sync-NAVTenant -ServerInstance $ServerInstance -Force -ErrorAction Inquire
            Sync-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -ErrorAction Inquire
            Install-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Force -ErrorAction Inquire
        }

        2 { #Actualizar
            $Extension = Get-Extension
            $ExtensionName = $Extension.Name.ToString()
            $OldExtensionVersion = $Extension.Version.ToString()

            $ExtensionPath = Get-FileName
            $NewExtensionVersion = $ExtensionPath.SubString($ExtensionPath.LastIndexOf("_") + 1, $ExtensionPath.LastIndexOf(".") - 1 - $ExtensionPath.LastIndexOf("_"))

            Write-Host "Actualizando..."
        
            Publish-NAVApp -ServerInstance $ServerInstance -Path $ExtensionPath -SkipVerification -ErrorAction Inquire
            Sync-NAVTenant -ServerInstance $ServerInstance -Force -ErrorAction Inquire
            Sync-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -ErrorAction Inquire
            Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -ErrorAction Inquire
            Unpublish-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $OldExtensionVersion -ErrorAction Inquire
        }

        3 { #Forzar Actualizar
            $Extension = Get-Extension
            $ExtensionName = $Extension.Name.ToString()
            $OldExtensionVersion = $Extension.Version.ToString()

            $ExtensionPath = Get-FileName
            $NewExtensionVersion = $ExtensionPath.SubString($ExtensionPath.LastIndexOf("_") + 1, $ExtensionPath.LastIndexOf(".") - 1 - $ExtensionPath.LastIndexOf("_"))

            Write-Host "Actualizando..."
        
            Publish-NAVApp -ServerInstance $ServerInstance -Path $ExtensionPath -SkipVerification -ErrorAction Inquire
            Sync-NAVTenant -ServerInstance $ServerInstance -Force -ErrorAction Inquire
            Uninstall-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $OldExtensionVersion -ErrorAction Inquire
            Sync-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -Mode ForceSync -ErrorAction Inquire
            Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -ErrorAction Inquire
            Unpublish-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $OldExtensionVersion -ErrorAction Inquire
        }

        4 { #Recreate
            $Extension = Get-Extension
            $ExtensionName = $Extension.Name.ToString()
            $OldExtensionVersion = $Extension.Version.ToString()

            $ExtensionPath = Get-FileName
            $NewExtensionVersion = $ExtensionPath.SubString($ExtensionPath.LastIndexOf("_") + 1, $ExtensionPath.LastIndexOf(".") - 1 - $ExtensionPath.LastIndexOf("_"))
        
            Write-Host "Actualizando..."

            Publish-NAVApp -ServerInstance $ServerInstance -Path $ExtensionPath -SkipVerification -ErrorAction Inquire
            Sync-NAVTenant -ServerInstance $ServerInstance -Force -ErrorAction Inquire
            Uninstall-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $OldExtensionVersion -ErrorAction Inquire
            Sync-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -Mode Clean -ErrorAction Inquire
            Sync-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -ErrorAction Inquire
            Install-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -Force -ErrorAction Inquire
            Unpublish-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $OldExtensionVersion -ErrorAction Inquire
        }

        5 { #Despublicar
            $Extension = Get-Extension
            $ExtensionName = $Extension.Name.ToString()
            $ExtensionVersion = $Extension.Version.ToString()

            Write-Host "Despublicando..."
        
            Uninstall-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $ExtensionVersion -ErrorAction Inquire
            Unpublish-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $ExtensionVersion -ErrorAction Inquire
        }
    
        6 { #Reinstalar
            $Extension = Get-Extension
            $ExtensionName = $Extension.Name.ToString()
            $OldExtensionVersion = $Extension.Version.ToString()

            $ExtensionPath = Get-FileName
            $NewExtensionVersion = $ExtensionPath.SubString($ExtensionPath.LastIndexOf("_") + 1, $ExtensionPath.LastIndexOf(".") - 1 - $ExtensionPath.LastIndexOf("_"))

            Write-Host "Actualizando..."
        
            Publish-NAVApp -ServerInstance $ServerInstance -Path $ExtensionPath -SkipVerification -ErrorAction Inquire
            Sync-NAVTenant -ServerInstance $ServerInstance -Force -ErrorAction Inquire
            Uninstall-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $OldExtensionVersion -ErrorAction Inquire
            Sync-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -Mode Development -ErrorAction Inquire
            Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Name $ExtensionName -Version $NewExtensionVersion -ErrorAction Inquire
            Unpublish-NAVApp -ServerInstance $ServerInstance -Name $ExtensionName -Version $OldExtensionVersion -ErrorAction Inquire
        }

        7 { #Publicar
            $ExtensionPath = Get-FileName
            $ExtensionName = $ExtensionPath.SubString($ExtensionPath.IndexOfAny("_", $ExtensionPath.LastIndexOf("\")) + 1, $ExtensionPath.LastIndexOf("_") - 1 - $ExtensionPath.IndexOfAny("_", $ExtensionPath.LastIndexOf("\")))

            Write-Host "Instalando..."

            Publish-NAVApp -ServerInstance $ServerInstance -Path $ExtensionPath -SkipVerification -ErrorAction Inquire
        }
        8 { #Cambiar licencia
            $ExtensionPath = Get-FileName

            Import-NAVServerLicense -LicenseFile $ExtensionPath -ServerInstance $ServerInstance
            Restart-NAVServerInstance -ServerInstance $ServerInstance
        }
    }
    ErrorMessage(99)
}
while($opt -ne 0)
