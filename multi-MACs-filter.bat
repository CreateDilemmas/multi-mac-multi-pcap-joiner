@echo off
setlocal EnableDelayedExpansion
REM c9d0a14b43b0798dc41f057cdb02fe09
REM Check if macs.txt exists
if not exist "macs.txt" (
    echo ERROR: macs.txt not found in the script directory.
    pause
    exit /b 1
)

REM Set tool paths (adjust if Wireshark is installed elsewhere)
set "TSHARK=C:\Program Files\Wireshark\tshark.exe"
set "MERGECAP=C:\Program Files\Wireshark\mergecap.exe"

REM Check if tools exist
if not exist "%TSHARK%" (
    echo ERROR: tshark not found at %TSHARK%. Update the path in the script.
    pause
    exit /b 1
)
if not exist "%MERGECAP%" (
    echo ERROR: mergecap not found at %MERGECAP%. Update the path in the script.
    pause
    exit /b 1
)

REM Process each MAC from macs.txt
for /f "tokens=*" %%m in (macs.txt) do (
    set "mac=%%m"
    set "sanitized_mac=!mac::=-!"
    echo Processing MAC: !mac!

    REM Filter each .pcap file for this MAC
    for %%f in ("%~dp0*.pcap") do (
        echo Filtering %%f for MAC !mac!...
        "%TSHARK%" -r "%%f" -Y "eth.addr == !mac!" -w "%~dp0temp_!sanitized_mac!_%%~nxf"
        if errorlevel 1 (
            echo ERROR: tshark failed for %%f with MAC !mac!.
        )
    )

    REM Merge the filtered files for this MAC
    echo Merging filtered files for MAC !mac! into filtered_!sanitized_mac!.pcap...
    "%MERGECAP%" -w "%~dp0filtered_!sanitized_mac!.pcap" "%~dp0temp_!sanitized_mac!_*.pcap"
    if errorlevel 1 (
        echo ERROR: mergecap failed for MAC !mac!.
    ) else (
        echo Merge successful for MAC !mac!.
        del "%~dp0temp_!sanitized_mac!_*.pcap"
        if errorlevel 1 (
            echo ERROR: Failed to delete temporary files for MAC !mac!.
        ) else (
            echo Temporary files deleted for MAC !mac!.
        )
    )
)

echo All MACs processed.
pause
endlocal