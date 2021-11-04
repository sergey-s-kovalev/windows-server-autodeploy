#################################################
# Скрипт выполняется от имени Administrator !!! #
#################################################

# Проверка на то, что скрипт уже выполнялся
If (Test-Path -Path "C:\Temp") {Exit}

# Создаем папку в корне диска C:
New-Item -ItemType Directory -Path C:\Temp -Verbose

# Включаем логирование операций в скрипте
Start-Transcript -OutputDirectory C:\Temp

Write-host $env:USERNAME -Verbose
# Переименовываем сервер
Rename-Computer -NewName Win2022Std -Verbose

# Установка часового пояса GMT+7
Set-TimeZone -Id "North Asia Standard Time" -Verbose

# Московское время GMT+3
#Set-TimeZone -Id "Russian Standard Time"

# Уменьшаем строку поиска около Пуск до значка
# Эта команда должна выполняться под самим пользователем
# REG ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f
Set-Itemproperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 1 -Verbose

# Отключаем флоппи диск (для возврата -Value 3)
Set-Itemproperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\flpydisk' -Name 'Start' -Value 4 -Verbose



# Меняем букву диска оптического привода на S:\
$OpticalDrive = (Get-WmiObject win32_volume | ? {$_.DriveType -eq 5})
$OpticalDrive.DriveLetter = "S:"
$OpticalDrive.Put() | out-null

Copy-Item -Path S:\software\*.msi -Destination C:\Temp -Include *.msi -Force

# Установка софта с диска оптического привода
$Agrs = '/I ' + 'C:\Temp\7z1900-x64.msi /quiet'
Start-Process msiexec.exe -Wait -ArgumentList $Agrs -Verbose
Remove-Item -Path 'C:\Temp\7z1900-x64.msi' -Force -Verbose

$Agrs = '/I ' + 'C:\Temp\Far20b1807.x64.20110203.msi /quiet'
Start-Process msiexec.exe -Wait -ArgumentList $Agrs -Verbose
Remove-Item -Path 'C:\Temp\Far20b1807.x64.20110203.msi' -Force -Verbose

# Отключаем оптический диск
$OpticalDrive = (Get-WmiObject win32_volume | ? {$_.DriveType -eq 5})
(New-Object -ComObject Shell.Application).Namespace(17).ParseName($OpticalDrive.Name).InvokeVerb("Eject")

# Задаем языки раскладки ввода клавиатуры, добавляем русскую раскладку
#Set-WinUserLanguageList -LanguageList en-US, ru-RU -Force -Verbose

#$UserLanguageList = Get-WinUserLanguageList -Verbose
#$UserLanguageList.Add("ru-RU")
#Set-WinUserLanguageList $UserLanguageList -Force -Confirm:$false -Verbose


#SCHTASKS /Create /S localhost /RU Administrator /RP 123456Qq /SC OnStart /TN Test /TR "cmd.exe /c mkdir C:\Temp1" /F /RL HIGHEST
#SCHTASKS /Run /S localhost /TN Test
#SCHTASKS /Delete /S localhost /TN cloud-init


# Изменяем размер файла подкачки
$computersys = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges -Verbose
$computersys.AutomaticManagedPagefile = $False
$computersys.Put()
$pagefile = Get-WmiObject -Query "Select * From Win32_PageFileSetting Where Name like '%pagefile.sys'"
$pagefile.InitialSize = 512
$pagefile.MaximumSize = 8192
$pagefile.Put()
#$pagefile.Delete()


# Удаляем Windows Defender
Uninstall-WindowsFeature -Name Windows-Defender


# Включаем RDP доступ к серверу
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" –Value 0

# Включаем правила
#Enable-NetFirewallRule -DisplayName "Remote Event Log Management*"
#Enable-NetFirewallRule -DisplayName "Virtual Machine Monitoring (DCOM-In)"
#Enable-NetFirewallRule -DisplayName "Virtual Machine Monitoring (Echo Request - ICMPv4-In)"


Stop-Transcript

# Перезагружаем сервер для следующего этапа установки
Start-Sleep -Seconds 10
Restart-Computer -Force



