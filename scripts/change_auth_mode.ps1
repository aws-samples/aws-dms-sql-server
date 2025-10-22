# Standalone script for SQL Server 2022 (version 16) by default
# For other versions, change MSSQL16 to: MSSQL13 (2016), MSSQL14 (2017), MSSQL15 (2019)
$registryPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQLServer"
$name = "LoginMode"
$value = "2"

if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
} else {
    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null
}
