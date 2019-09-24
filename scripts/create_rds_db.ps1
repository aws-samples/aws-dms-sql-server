$RDSSQLInstance = "${RDSEndpoint}"
$RDSSQLUser = "${Username}"
$RDSSQLPassword = "${UserPassword}"
$DBName = "${DBName}"
# Checking to see if the SqlServer module is already installed.
$SQLModuleCheck = Get-Module -ListAvailable SqlServer
if ($null -eq $SQLModuleCheck)
{
    write-host "SqlServer Module Not Found - Installing..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    # Installing module
    Install-Module -Name SqlServer -Confirm:$false -AllowClobber -Force
}
Import-Module SqlServer
# Creating SQL Query to create database
$SQLDBQuery = "create database $DBName"
# Running the SQL Query, setting result of query to $False if any errors caught
Try
{
    $SQLDBResult = $null
    $SQLDBResult = Invoke-SqlCmd -Query $SQLDBQuery -ServerInstance $RDSSQLInstance -Username $RDSSQLUser -Password $RDSSQLPassword
    $SQLQuerySuccess = $TRUE
}
Catch
{
    $SQLQuerySuccess = $FALSE
}
# Output of the results in cfn/logs
"SQLInstance: $RDSSQLInstance"
"SQLQueryResult: $SQLQuerySuccess"
"SQLQueryOutput:"
$SQLDBResult