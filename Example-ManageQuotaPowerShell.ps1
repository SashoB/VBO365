Clear-Host
Add-PSSnapin VeeamPSSnapin
Write-Host -BackgroundColor Green ("                                ")
Write-Host -BackgroundColor Green ("       VBO konfiguracija        ") -ForegroundColor Black
Write-Host -BackgroundColor Green ("                                ")

function Get-QuotasOnDisk() {
    param(
        [string]$Disk
    )

    $Quotas = Get-FsrmQuota | ?{$_.Path -like "$Disk*"} | Measure-Object -Property Size -Sum 
    
    $SUM = "{0:N0}" -f ($Quotas.sum / 1TB)
    $Result = New-Object -TypeName psobject
    $Result | Add-Member -MemberType NoteProperty -Name QuotaSUM -Value $SUM
    $Result | Add-Member -MemberType NoteProperty -Name DiskName -Value $Disk
    $Result
}

function Get-AllQuotasOnDisks() {
    $disks = Get-WmiObject Win32_LogicalDisk | ?{$_.VolumeName -like "LUN*"} |  %{ 
        $Result = Get-QuotasOnDisk -Disk "$($_.DeviceID)\"
        $Result | Add-Member -MemberType NoteProperty -Name FreeSpace -Value $("{0:N0}" -f ($_.FreeSpace / 1TB))
        $Result | Add-Member -MemberType NoteProperty -Name DiskSize -Value $("{0:N0}" -f ($_.Size / 1TB))
        $Result | Add-Member -MemberType NoteProperty -Name ClaimedPercent -Value  (($Result.QuotaSUM/$Result.DiskSize))
        $Result
    }
    $disks
}

function Get-AppropriateDisk() {
    param(
        [int]$Quota,
        [string]$MenuIzbira
    )
    $Quotas = Get-AllQuotasOnDisks
    $Moznosti = @() 
    foreach($Q in $Quotas) {
        #Če je rezerviranih kvot na disku toliko, da je razlika manjša od želje kvote ta disk preskočimo
        if(($Q.DiskSize - $Q.QuotaSUM) -lt $Quota)
        {
            continue
        }
        #Če je kvote za več kot 80% in razlika med diskom kvotami manjša od 10TB se priporoča dodajati drug disk, izjema je izbira 3 v menuju
        if($Q.QuotaSUM/$Q.DiskSize -gt 0.80 -and ($Q.DiskSize - $Q.QuotaSUM) -lt 10) {
            if($MenuIzbira -ne "3") {
                continue
            }
        }
        $Moznosti += $Q
    }
    $Moznosti
}




do {
    Write-Host (" = Izbira koraka = ")
    Write-Host ("1. Dodajanje novega uporabnika in nove kvote")
    Write-Host ("2. Dodajanje novega kvote obstoječemu uporabniku")
    Write-Host ("3. Povečanje obstoječe kvote obstoječemu uporabniku")
    Write-Host "Q: Pritisni 'Q' za izhod."

    $MenuIzbira = Read-Host ("Prosim, izberi svoj korak")
    switch ($MenuIzbira) {
        "1" { #"1. Dodajanje novega uporabnika in nove kvote"
            Write-Host ("1. Dodajanje novega uporabnika in nove kvote")
            $TenantName = Read-Host("Vnesi ime tenanta")
            $Quota = Read-Host("Vnesi kvoto (v TB)")
            $PR = Get-AppropriateDisk
            if($PR.Count -eq 0) {
                Write-Host ("Na nobenem disku ni zaznati dovolj prostora za vnešeno kvoto")
                return
            } 
            $MIN = ($PR | Measure-Object -Property ClaimedPercent -Minimum).Minimum
            $SelectedDisk = $PR | ? {$_.ClaimedPercent -eq $MIN } | Select-Object -First 1
            $FreeSpaceTB = $SelectedDisk.FreeSpace

            Write-Host ("Mapa bo kreirana na disku $($SelectedDisk.DiskName), ki je rezerviran $($SelectedDisk.ClaimedPercent)%")

            $BackupFolder = "$($SelectedDisk.DiskName)Backups"
            $proxy = Get-VBOProxy -Id "6b001d3e-dd88-4b50-8e51-b60e89f66d37"
            $TARGETDIR = $BackupFolder+"\"+$TenantName


            if(!(Test-Path -Path $TARGETDIR )){
                New-Item -ItemType directory -Path $TARGETDIR
                $QuotaCorrect = [Int]$Quota*1TB
                $QuotaCorrect=[Uint64]$QuotaCorrect
                New-FsrmQuota -Path "$TARGETDIR" -Description "VO365 limit $Quota TB" -Size $QuotaCorrect
                Add-VBORepository -Name "$TenantName" -Path "$TARGETDIR" -Proxy $proxy -Description
            } else {
                Write-Host ("Mapa s tem imenom že obstaja, če želiš spremeniti kvoto izberi število 3.")
            }
            
            
            return
        }
        "2" { #"2. Dodajanje novega kvote obstoječemu uporabniku"
            Write-Host ("2. Dodajanje novega kvote obstoječemu uporabniku")
            $TenantName = Read-Host("Vnesi ime tenanta")
            $Quota = Read-Host("Vnesi kvoto (v TB)")
            $RepNR = $(Get-VBORepository | ?{$_.Name -eq $TenantName -or $_.Name -like "$($TenantName)_REP*"}).Count + 1 
            $PR = Get-AppropriateDisk
            if($PR.Count -eq 0) {
                Write-Host ("Na nobenem disku ni zaznati dovolj prostora za vnešeno kvoto")
                return
            } 
            $MIN = ($PR | Measure-Object -Property ClaimedPercent -Minimum).Minimum
            $SelectedDisk = $PR | ? {$_.ClaimedPercent -eq $MIN } | Select-Object -First 1
            $FreeSpaceTB = $SelectedDisk.FreeSpace

            Write-Host ("Mapa bo kreirana na disku $($SelectedDisk.DiskName), ki je rezerviran $($SelectedDisk.ClaimedPercent)%")

            $BackupFolder = "$($SelectedDisk.DiskName)Backups"
            $proxy = Get-VBOProxy -Id "6b001d3e-dd88-4b50-8e51-b60e89f66d37"
            $TARGETDIR = $BackupFolder+"\"+$TenantName+"_REP"+$RepNR


            if(!(Test-Path -Path $TARGETDIR )){
                New-Item -ItemType directory -Path $TARGETDIR
                $QuotaCorrect = [Int]$Quota*1TB
                $QuotaCorrect=[Uint64]$QuotaCorrect
                New-FsrmQuota -Path "$TARGETDIR" -Description "VO365 limit $Quota TB" -Size $QuotaCorrect
                Add-VBORepository -Name "$TenantName`_REP$RepNR" -Path "$TARGETDIR" -Proxy $proxy -Description "Dodatna kvota uporabnika $TenantName"
            } else {
                Write-Host ("Mapa s tem imenom že obstaja, če želiš spremeniti kvoto izberi število 3.")
            }
            return
        }
        "3" { #"3. Povečanje obstoječe kvote obstoječemu uporabniku"
            Write-Host ("3. Povečanje obstoječe kvote obstoječemu uporabniku")
            $TenantName = Read-Host("Vnesi ime kvote kot je vidna v Veeam vmesiku")
            $Quota = Read-Host("Vnesi skupno kvoto (v TB)")

            Set-FsrmQuota -Path "$TARGETDIR" -Description "VO365 limit $Quota TB" -Size $QuotaCorrect
            return
        }
        "q" {
            return
        }
        
    }
    pause
}
until ($input -eq 'q')

