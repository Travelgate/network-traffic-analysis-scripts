$output_file = "output_metrics.txt"

Start-Transcript -Path $output_file -Append

$current_utc_time = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
Write-Output "Script executed at: $current_utc_time"

$response = Invoke-WebRequest -Uri 'https://api.travelgatex.com' -Method Get -UseBasicParsing
$curl_metrics = Invoke-RestMethod -Uri 'https://api.travelgatex.com' -Method Get -Headers @{"Accept"="application/json"} -Verbose -DisableKeepAlive:$true 3>&1 2>&1 | Select-String -Pattern "(lookup|connect|appconnect|pretransfer|redirect|starttransfer|total) \= ([0-9.]+)"

$metrics = @{}
foreach ($metric in $curl_metrics) {
    if ($metric -match "lookup = ([0-9.]+)") { $metrics["time_namelookup"] = $matches[1] }
    if ($metric -match "connect = ([0-9.]+)") { $metrics["time_connect"] = $matches[1] }
    if ($metric -match "appconnect = ([0-9.]+)") { $metrics["time_appconnect"] = $matches[1] }
    if ($metric -match "pretransfer = ([0-9.]+)") { $metrics["time_pretransfer"] = $matches[1] }
    if ($metric -match "redirect = ([0-9.]+)") { $metrics["time_redirect"] = $matches[1] }
    if ($metric -match "starttransfer = ([0-9.]+)") { $metrics["time_starttransfer"] = $matches[1] }
    if ($metric -match "total = ([0-9.]+)") { $metrics["time_total"] = $matches[1] }
}

$location_data = Invoke-RestMethod -Uri 'https://ipinfo.io/json'

$dns_servers = Get-DnsClientServerAddress -AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses

$ip = $location_data.ip
$city = $location_data.city
$region = $location_data.region
$country = $location_data.country

Write-Output "City: $city"
Write-Output "Region: $region"
Write-Output "Country: $country"
Write-Output "DNS Servers: $($dns_servers -join ', ')"
Write-Output "Origin IP: $ip"
Write-Output "Destination IP: $($response.Headers['X-Forwarded-For'])"
Write-Output "----------------"
Write-Output "Time Statistics:"

function Apply-Color {
param (
[double]$time,
[string]$label
)
if ($time -lt 0.5) {
Write-Output -ForegroundColor Green "$label: $time sec"
} elseif ($time -gt 1.5) {
Write-Output -ForegroundColor Red "$label: $time sec"
} elseif ($time -ge 0.5) {
Write-Output -ForegroundColor Yellow "$label: $time sec"
} else {
Write-Output "$label: $time sec"
}
}

Apply-Color -time $metrics["time_namelookup"] -label "Time to Name Lookup"
Apply-Color -time $metrics["time_connect"] -label "Time to Connect"
Apply-Color -time $metrics["time_appconnect"] -label "Time to App Connect"
Apply-Color -time $metrics["time_pretransfer"] -label "Time to PreTransfer"
Apply-Color -time $metrics["time_redirect"] -label "Time for Redirection"
Apply-Color -time $metrics["time_starttransfer"] -label "Time to Start Transfer"
Apply-Color -time $metrics["time_total"] -label "Total Time"

Write-Output "----------------"
tracert api.travelgatex.com | ForEach-Object {Write-Output $_}
Write-Output "----------------"

Stop-Transcript
