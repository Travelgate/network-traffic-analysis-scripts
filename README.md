# API Performance Monitor
This Bash script is a tool designed to monitor and log the performance of connections to the TravelgateX API. It provides detailed metrics on response times and network statistics, helping to identify bottlenecks and improve the efficiency of API connections.

## Features
Time metrics logging: Time to name lookup, connect, app connect, pre-transfer, and more.
Color-coded statistics: Critical times are shown in red, while optimal times in green.
Location information: Includes location data based on the destination and origin IPs.
Detailed output: Results include destination IP, total time, and other key details.

## Requirements
* Bash shell
* curl
* jq
* Internet access

## Usage
Clone the repository to your local machine using Git:

```$ git clone https://github.com/Travelgate/network-traffic-analysis-scripts.git```

Navigate to the script directory:

```$ cd network-traffic-analysis-scripts```

Run the script:

```$ bash api_performance_monitor.sh```

## Contributing
If you would like to contribute to this project, you can do so via GitHub pull requests or by submitting issues if you find bugs or potential improvements.
