# VBO Report
Used to retrieve tenant license usage into one MySQL DB for reporting.

## TenantScript.ps1
1. Download script (TenantScript.ps1) to tenant VBO365 server and if possible save in the same folder as is set inside script for logs
2. Set required variables in the script - you set TenantName and TenantId in CreateTenant.php script
3. After that create task in TaskScheduler
```
Create Basic Task
Set name
Set trigger to monthly
In the months field select all months
In the days field select on which date you want to send usage data
Leave Action to Start a program
Set program to powershell.exe
Set argument to (without single quotes) '-WindowStyle Hidden -File "C:\<path to script>\TenantScript.ps1"'
At finish select also to open Properties dialog
In the Properties set which user should run the task if not current and select to run wheter user is logged on or not
```
