### Batch Script (.bat)

```batch
@echo off
setlocal enabledelayedexpansion

set output_file=output_metrics.txt

echo Script executed at: %date%T%time%Z > %output_file%

for /f "tokens=*" %%i in ('curl -L -s -o NUL -w "%%{time_namelookup} %%{time_connect} %%{time_appconnect} %%{time_pretransfer} %%{time_redirect} %%{time_starttransfer} %%{time_total} %%{remote_ip}" "https://api.travelgatex.com"') do set times=%%i

for /f "tokens=1-8" %%a in ("%times%") do (
    set time_namelookup=%%a
    set time_connect=%%b
    set time_appconnect=%%c
    set time_pretransfer=%%d
    set time_redirect=%%e
    set time_starttransfer=%%f
    set time_total=%%g
    set dest_ip=%%h
)

for /f "tokens=*" %%i in ('curl -s https://ipinfo.io/json') do set location_data=%%i

for /f "tokens=*" %%i in ('nslookup -type=NS 2>nul') do (
    set dns_servers=!dns_servers! %%i
)

set ip=%location_data:~6,14%
set city=%location_data:~29,13%
set region=%location_data:~48,14%
set country=%location_data:~66,2%

echo City: %city% >> %output_file%
echo Region: %region% >> %output_file%
echo Country: %country% >> %output_file%
echo DNS Servers: %dns_servers% >> %output_file%
echo Origin IP: %ip% >> %output_file%
echo Destination IP: %dest_ip% >> %output_file%
echo ---------------- >> %output_file%
echo Time Statistics: >> %output_file%

call :apply_color %time_namelookup% "Time to Name Lookup" >> %output_file%
call :apply_color %time_connect% "Time to Connect" >> %output_file%
call :apply_color %time_appconnect% "Time to App Connect" >> %output_file%
call :apply_color %time_pretransfer% "Time to PreTransfer" >> %output_file%
call :apply_color %time_redirect% "Time for Redirection" >> %output_file%
call :apply_color %time_starttransfer% "Time to Start Transfer" >> %output_file%
call :apply_color %time_total% "Total Time" >> %output_file%
echo ---------------- >> %output_file%

tracert api.travelgatex.com >> %output_file%
echo ---------------- >> %output_file%

:end
exit /b

:apply_color
set time=%1
set label=%2
if %time% LSS 0.5 (
    echo %label%: %time% sec
) else if %time% GTR 1.5 (
    echo %label%: %time% sec
) else (
    echo %label%: %time% sec
)
exit /b
