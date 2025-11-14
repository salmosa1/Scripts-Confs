function SignFromBCContainter {
    Param (
        [string] $containerName = $bcContainerHelperConfig.defaultContainerName, 
        [Parameter(Mandatory=$true)] [string] $appFile,
        [Parameter(Mandatory=$true)] [string] $CertificateThumbprint,
        [Parameter(Mandatory=$false)] [string] $timeStampServer = $bcContainerHelperConfig.timeStampServer,
        [Parameter(Mandatory=$false)] [string] $digestAlgorithm = $bcContainerHelperConfig.digestAlgorithm
    )

    $containerAppFile = Get-BcContainerPath -containerName $containerName -path $appFile
    if ("$containerAppFile" -eq "") {
        throw "The app ($appFile)needs to be in a folder, which is shared with the container $containerName"
    }

    Invoke-ScriptInBcContainer -containerName $containerName -useSession:$false -ScriptBlock { 
        Param($appFile, $CertificateThumbprint, $timeStampServer, $digestAlgorithm) 

        if (!(Test-Path "C:\Windows\System32\msvcr120.dll")) {
            Write-Host "Downloading vcredist_x86"
            (New-Object System.Net.WebClient).DownloadFile('https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/prerequisites/vcredist_x86.exe','c:\run\install\vcredist_x86.exe')
            Write-Host "Installing vcredist_x86"
            start-process -Wait -FilePath c:\run\install\vcredist_x86.exe -ArgumentList /q, /norestart
            Write-Host "Downloading vcredist_x64"
            (New-Object System.Net.WebClient).DownloadFile('https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/prerequisites/vcredist_x64.exe','c:\run\install\vcredist_x64.exe')
            Write-Host "Installing vcredist_x64"
            start-process -Wait -FilePath c:\run\install\vcredist_x64.exe -ArgumentList /q, /norestart
        }

        if (!(Test-Path "C:\Windows\System32\vcruntime140_1.dll")) {
            Write-Host "Downloading vcredist_x64 (version 140)"
            (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vc_redist.x64.exe','c:\run\install\vcredist_x64-140.exe')
            Write-Host "Installing vcredist_x64 (version 140)"
            start-process -Wait -FilePath c:\run\install\vcredist_x64-140.exe -ArgumentList /q, /norestart
        }
    
        if (Test-Path "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe") {
            $signToolExe = (get-item "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe").FullName
        } else {
            Write-Host "Downloading Signing Tools"
            $winSdkSetupExe = "c:\run\install\winsdksetup.exe"
            $winSdkSetupUrl = "https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/prerequisites/winsdksetup.exe"
            (New-Object System.Net.WebClient).DownloadFile($winSdkSetupUrl,$winSdkSetupExe)
            Write-Host "Installing Signing Tools"
            Start-Process $winSdkSetupExe -ArgumentList "/features OptionId.SigningTools /q" -Wait
            if (!(Test-Path "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe")) {
                throw "Cannot locate signtool.exe after installation"
            }
            $signToolExe = (get-item "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe").FullName
        }

        Write-Host "Signing $appFile"
        $attempt = 1
        $maxAttempts = 5
        do {
            try {
                & "$signtoolexe" @("sign", "/sha1", "$CertificateThumbprint", "/fd", $digestAlgorithm, "/td", $digestAlgorithm, "/tr", "$timeStampServer", "/v", "$appFile") | Write-Host                    
                break
            } catch {
                if ($attempt -ge $maxAttempts) {
                    throw
                }
                else {
                    $seconds = [Math]::Pow(4,$attempt)
                    Write-Host "Signing failed, retrying in $seconds seconds"
                    $attempt++
                    Start-Sleep -Seconds $seconds
                }
            }
        } while ($attempt -le $maxAttempts)
    } -ArgumentList $containerAppFile, $CertificateThumbprint, $timeStampServer, $digestAlgorithm
}

function SignFromLocal {
    Param (        
        [Parameter(Mandatory=$true)] [string] $appFile,
        [Parameter(Mandatory=$true)] [string] $CertificateThumbprint,
        [Parameter(Mandatory=$false)] [string] $timeStampServer = $bcContainerHelperConfig.timeStampServer,
        [Parameter(Mandatory=$false)] [string] $digestAlgorithm = $bcContainerHelperConfig.digestAlgorithm
    )

    if (!(Test-Path "C:\Windows\System32\msvcr120.dll")) {
        Write-Host "Downloading vcredist_x86"
        (New-Object System.Net.WebClient).DownloadFile('https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/prerequisites/vcredist_x86.exe','c:\run\install\vcredist_x86.exe')
        Write-Host "Installing vcredist_x86"
        start-process -Wait -FilePath c:\run\install\vcredist_x86.exe -ArgumentList /q, /norestart
        Write-Host "Downloading vcredist_x64"
        (New-Object System.Net.WebClient).DownloadFile('https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/prerequisites/vcredist_x64.exe','c:\run\install\vcredist_x64.exe')
        Write-Host "Installing vcredist_x64"
        start-process -Wait -FilePath c:\run\install\vcredist_x64.exe -ArgumentList /q, /norestart
    }

    if (!(Test-Path "C:\Windows\System32\vcruntime140_1.dll")) {
        Write-Host "Downloading vcredist_x64 (version 140)"
        (New-Object System.Net.WebClient).DownloadFile('https://aka.ms/vs/17/release/vc_redist.x64.exe','c:\run\install\vcredist_x64-140.exe')
        Write-Host "Installing vcredist_x64 (version 140)"
        start-process -Wait -FilePath c:\run\install\vcredist_x64-140.exe -ArgumentList /q, /norestart
    }
    
    if (Test-Path "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe") {
        $signToolExe = (get-item "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe").FullName
    } else {
        Write-Host "Downloading Signing Tools"
        $winSdkSetupExe = "c:\run\install\winsdksetup.exe"
        $winSdkSetupUrl = "https://bcartifacts-exdbf9fwegejdqak.b02.azurefd.net/prerequisites/winsdksetup.exe"
        (New-Object System.Net.WebClient).DownloadFile($winSdkSetupUrl,$winSdkSetupExe)
        Write-Host "Installing Signing Tools"
        Start-Process $winSdkSetupExe -ArgumentList "/features OptionId.SigningTools /q" -Wait
        if (!(Test-Path "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe")) {
            throw "Cannot locate signtool.exe after installation"
        }
        $signToolExe = (get-item "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe").FullName
    }

    Write-Host "Signing $appFile"
    $attempt = 1
    $maxAttempts = 5
    do {
        try {
            & "$signtoolexe" @("sign", "/sha1", "$CertificateThumbprint", "/fd", $digestAlgorithm, "/td", $digestAlgorithm, "/tr", "$timeStampServer", "/v", "$appFile") | Write-Host                    
            break
        } catch {
            if ($attempt -ge $maxAttempts) {
                throw
            }
            else {
                $seconds = [Math]::Pow(4,$attempt)
                Write-Host "Signing failed, retrying in $seconds seconds"
                $attempt++
                Start-Sleep -Seconds $seconds
            }
        }
    } while ($attempt -le $maxAttempts)
}

function VerifySign {
    Param (        
        [Parameter(Mandatory=$true)] [string] $appFile
    )

    $signToolExe = (get-item "C:\Program Files (x86)\Windows Kits\10\bin\*\x64\SignTool.exe").FullName

    Write-Host "Verifying $appFile"
    $attempt = 1
    $maxAttempts = 5
    do {
        try {

            & "$signtoolexe" @("verify", "/pa", "$appFile") | Write-Host                    
            break
        } catch {
            if ($attempt -ge $maxAttempts) {
                throw
            }
            else {
                $seconds = [Math]::Pow(4,$attempt)
                Write-Host "Signing failed, retrying in $seconds seconds"
                $attempt++
                Start-Sleep -Seconds $seconds
            }
        }
    } while ($attempt -le $maxAttempts)

}


$CertificateThumbprint = "1412BE5930D353ECF514A137887193E67408EC43"
$timeStampServer = "http://time.certum.pl"
$digestAlgorithm = "SHA256"

$appFile = "C:\Firmas\Servicios Implantación DynamizaTIC, S.L._Dyn Licencias_26.0.0.2.app"
SignFromLocal -appFile $appFile -CertificateThumbprint $CertificateThumbprint -timeStampServer $timeStampServer -digestAlgorithm $digestAlgorithm
VerifySign -appFile $appFile

$appFile = "C:\Firmas\Servicios Implantación DynamizaTIC, S.L._Dyn Nominas_26.0.0.2.app"
SignFromLocal -appFile $appFile -CertificateThumbprint $CertificateThumbprint -timeStampServer $timeStampServer -digestAlgorithm $digestAlgorithm
VerifySign -appFile $appFile