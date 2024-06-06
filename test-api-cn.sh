#!/bin/bash

output_file="output_metrics.txt"

#Start capturing everything to log
exec &> >(tee -a "$output_file")

#Print and log the current UTC time
current_utc_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "Script executed at: $current_utc_time"

read -r time_namelookup time_connect time_appconnect time_pretransfer time_redirect time_starttransfer time_total dest_ip <<<$(curl -L -s -o /dev/null -w "%{time_namelookup} %{time_connect} %{time_appconnect} %{time_pretransfer} %{time_redirect} %{time_starttransfer} %{time_total} %{remote_ip}" 'https://api-cn.travelgatex.com.'/)

apply_color() {
  local time=$1
  local label=$2
  if (( $(echo "$time < 0.5" | bc -l) )); then
    echo -e "\e[32m${label}: ${time} sec\e[0m"  # green
  elif (( $(echo "$time > 1.5" | bc -l) )); then
    echo -e "\e[31m${label}: ${time} sec\e[0m"  # red
  elif (( $(echo "$time >= 0.5" | bc -l) )); then
    echo -e "\e[33m${label}: ${time} sec\e[0m"  # yellow
  else
    echo "${label}: ${time} sec"
  fi
}

# Fetch location data using ipinfo.io and curl
location_data=$(curl -s https://ipinfo.io/json)

# Fetch DNS Server
dns_servers=$(cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}')

# Parse specific fields using jq
ip=$(echo "$location_data" | jq -r '.ip')
city=$(echo "$location_data" | jq -r '.city')
region=$(echo "$location_data" | jq -r '.region')
country=$(echo "$location_data" | jq -r '.country')

# Display the parsed data
echo "City: $city"
echo "Region: $region"
echo "Country: $country"
echo "DNS Servers: $dns_servers"
echo "Origin IP: $ip"
echo "Destination IP: $dest_ip"
echo "----------------"
echo "Time Statistics:"
apply_color "$time_namelookup" "Time to Name Lookup" "Time taken to resolve the domain name into an IP address"
apply_color "$time_connect" "Time to Connect" "Time it takes to establish a TCP connection with the server"
apply_color "$time_appconnect" "Time to App Connect" "Time taken to complete the SSL/TLS handshake if applicable"
apply_color "$time_pretransfer" "Time to PreTransfer" "Time from the start until just before the data transfer begins"
apply_color "$time_redirect" "Time for Redirection" "Total time taken for all redirections before the final transfer"
apply_color "$time_starttransfer" "Time to Start Transfer" "Time until the first byte is received after sending the request"
apply_color "$time_total" "Total Time" "Total duration from the start of the operation to its completion"
echo "----------------"
traceroute api.travelgatex.com
echo "----------------"
#Stop capturing to log
exec &> /dev/tty
