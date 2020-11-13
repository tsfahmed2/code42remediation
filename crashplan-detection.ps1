
	function Get-InstalledApps
	{
		#Write-host  'Start Get-InstalledApps'
		if ([IntPtr]::Size -eq 4) {
			$regpath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
			#Write-host 'Found x86'
		}
		else {
			$regpath = @(
				'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
				'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
			)
			#Write-host 'Found x64'
		}
		Get-ItemProperty $regpath | .{process{if($_.DisplayName -and $_.UninstallString) { $_ } }} | Select-Object DisplayName, Publisher, InstallDate, DisplayVersion, UninstallString |Sort DisplayName
	}

	#$CurrentReaderVersion = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Where-Object{$_.DisplayName -like "*Adobe*" -and $_.DisplayName -like "*Reader*"}
	$appToMatch = 'Code42'
	$result = Get-InstalledApps | Where-Object { $_.DisplayName -eq $appToMatch }
    
    $code42loginfile = "$env:ProgramData\CrashPlan\conf\service.login"

    if (($result -ne $null) -and (Test-Path $code42loginfile)){
        Write-Host "Code42 is installed and signed in"
        exit 0
    }
    elseif ($result -eq $null) {
        Write-Host "Crashplan is not installed"
        exit 1
    }
    elseif (($result -ne $null) -and ((Test-Path $code42loginfile)-eq $false)) {
        Write-Host "Crashplan is installed but user is not signed in"
        exit 1
    }