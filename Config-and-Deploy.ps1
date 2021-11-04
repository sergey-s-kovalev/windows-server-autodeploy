##########################################
# Скрипт выполняется от имени SYSTEM !!! #
##########################################

# Проверка на то, что скрипт уже выполнялся
If (Test-Path -Path "C:\Temp") {Exit}

# Переименовываем сервер
Rename-Computer -NewName Server1C

# Создаем папку в корне диска C:
New-Item -ItemType Directory -Path C:\Temp

# Установка часового пояса GMT+7
Set-TimeZone -Id "North Asia Standard Time"

# Московское время
#Set-TimeZone -Id "Russian Standard Time"

# Эта команда должна выполняться под самим пользователем
# REG ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d 1 /f
# Set-Itemproperty -path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Value 1

# Установка софта с диска оптического привода
$CDDrive = ((Get-WmiObject win32_volume | ? {$_.DriveType -eq 5}).DriveLetter)
# Устанавливаем софт
$Agrs = '/I ' + $CDDrive + '\software\7z1900-x64.msi /quiet'
Start-Process msiexec.exe -Wait -ArgumentList $Agrs
$Agrs = '/I ' + $CDDrive + '\software\Far20b1807.x64.20110203.msi /quiet'
Start-Process msiexec.exe -Wait -ArgumentList $Agrs

# Перезагружаем сервер для следующего этапа установки
Start-Sleep -Seconds 10
Restart-Computer -Force



