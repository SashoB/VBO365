# Please set variables $TenantName, $TenantId and $URL


#Set logging
Start-Transcript -Path 'C:\Scripts\VBOReport_log.txt' -Force

#Set Tenant Details
$TenantName = "TEST_Tenant"
$TenantId = "213-4523-456"

#Send Data to Server 
$URL = "https://www.example.com/VBOReport/"

#Get License Details
$LicenseDetails = Get-VBOLicense
$UsedLicenses = $LicenseDetails.UsedNumber
$TotalLicenses = $LicenseDetails.TotalNumber

$Body = @{
    TenantName = $TenantName
    TenantId = $TenantId
    UsedLicenses =$UsedLicenses
    TotalLicenses = $TotalLicenses
    LicenseDetails = ($LicenseDetails | ConvertTo-Json)
}

Invoke-RestMethod -Method 'Post' -Uri $URL -Body $body

Stop-Transcript
