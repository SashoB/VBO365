Import-Module -Name ExchangeOnlineManagement
ExchangeOnlineManagement\Connect-ExchangeOnline

Write-Host "Gathering Stats, Please Wait.." 
$TotalArchiveMailboxes = 0
$TotalArchiveMailboxeData = 0;
$Mails = Get-EXOMailbox -Archive -resultsize unlimited

$Mails | % {
    $TotalArchiveMailboxes++;
    $Size = (Get-EXOMailboxStatistics -archive -Identity $_.Identity);
    if(!$Size) { $Size1 = 0; } else { $TotalArchiveMailboxeData += $Size.TotalItemSize.value.Tobytes()}    
}

$MB = $TotalArchiveMailboxeData/1024/1024
$GB = $MB/1024
$TB = $GB/1024


Write-Host "Number of Archive Mailboxes: $TotalArchiveMailboxes"
if($TB -gt 1) {
    Write-Host "Total size of Archive Mailboxes: $TB TB"
} elseif($GB -gt 1) {
    Write-Host "Total size of Archive Mailboxes: $GB GB"
} else {
    Write-Host "Total size of Archive Mailboxes: $MB MB"
}

Disconnect-ExchangeOnline -Confirm:$false | Out-Null
