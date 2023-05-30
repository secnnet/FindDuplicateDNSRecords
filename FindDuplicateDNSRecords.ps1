param (
    [Parameter(Mandatory = $true)]
    [string]$DnsServer,                   # DNS server parameter

    [Parameter(Mandatory = $true)]
    [string]$ZoneName,                    # DNS zone parameter

    [string]$ExcludeRecordNames = "",     # Exclude specific record names parameter

    [string]$OutputFile = "",             # Output file parameter

    [string]$EmailNotification = "",      # Email notification parameter

    [string]$RecordType = "A"             # Record type parameter, defaulting to A
)

# Validate DNS server parameter
if (-not (Test-Connection -ComputerName $DnsServer -Count 1 -Quiet)) {
    Write-Host "ERROR: DNS server '$DnsServer' is not reachable."
    Exit 1
}

# Query DNS server for resource records in the specified zone
try {
    $dnsRecords = Get-DnsServerResourceRecord -ComputerName $DnsServer -ZoneName $ZoneName -ErrorAction Stop
} catch {
    Write-Host "ERROR: Failed to retrieve DNS records from zone '$ZoneName' on DNS server '$DnsServer'."
    Exit 1
}

# Dictionary to store IP occurrence count
$ipCount = @{}
# Dictionary to store duplicate records by IP
$duplicateRecords = @{}

# Iterate through DNS records and count IP occurrences
foreach ($record in $dnsRecords) {
    if ($record.RecordType -eq $RecordType) {
        $ip = $record.RecordData.IPAddressToString

        if ($ipCount.ContainsKey($ip)) {
            $ipCount[$ip] += 1
            $duplicateRecords[$ip] += @($record)
        } else {
            $ipCount[$ip] = 1
            $duplicateRecords[$ip] = @($record)
        }
    }
}

# Find duplicate IP addresses
$duplicateIPs = $ipCount | Where-Object { $_.Value -gt 1 }

if ($duplicateIPs.Count -eq 0) {
    Write-Host "No duplicate IP addresses found."
    Exit
}

$results = @()

# Iterate through duplicate IP addresses and filter records
foreach ($duplicateIP in $duplicateIPs) {
    $ip = $duplicateIP.Key

    # Exclude specific record names
    $filteredRecords = $duplicateRecords[$ip] | Where-Object { $_.HostName -notlike $ExcludeRecordNames }

    if ($filteredRecords.Count -gt 1) {
        $result = [PSCustomObject]@{
            IP = $ip
            Occurrences = $duplicateIP.Value
            Records = $filteredRecords
        }
        $results += $result
    }
}

if ($results.Count -eq 0) {
    Write-Host "No duplicate IP addresses found after excluding specified record names."
    Exit
}

if ($OutputFile) {
    $results | Export-Csv -Path $OutputFile -NoTypeInformation
    Write-Host "Results saved to: $OutputFile"
}

if ($EmailNotification) {
    $mailParams = @{
        From = "sender@example.com"
        To = $EmailNotification
        Subject = "Duplicate DNS Records Found in Zone: $ZoneName"
        Body = "Duplicate DNS records have been found in the zone '$ZoneName'. Please review the attached CSV file for details."
        SmtpServer = "smtp.example.com"
        Attachments = $OutputFile
    }
    Send-MailMessage @mailParams
}

$results | ForEach-Object {
    $ip = $_.IP
    $occurrences = $_.Occurrences
    Write-Host "IP: $ip ($occurrences occurrences)"
    Write-Host "DNS Records:"
    $_.Records | ForEach-Object {
        $recordName = $_.HostName
        $recordTTL = $_.TimeToLive
        Write-Host "   - $recordName (TTL: $recordTTL)"
    }
    Write-Host
}
