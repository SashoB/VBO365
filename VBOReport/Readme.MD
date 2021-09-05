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

## VBOReporting.sql
Import VBOReporting.sql to MySQL installed on the server where you want to collect reports. You can do it on VBO Self-Service portal server.

## MonthlyCronInsert.php
Copy file MonthlyCronInsert.php to the same server as MySQL script from above. You can put it whereever you want.
After that create Cron using command
```
crontab -e
```
I Added following line, which will run script every 1 day of the month at 1 AM.
```
0 1 1 * * php /-path-to-script-/MonthlyCronInsert.php
```

## ShowLastReport.php
Put file ShowLastReport.php in the folder accessible from WEB. 
*File is not protected so it shows sensible data, protect it your way or use .htaccess (https://www.lcn.com/support/articles/how-to-password-protect-a-folder-on-your-website-with-htaccess/)
