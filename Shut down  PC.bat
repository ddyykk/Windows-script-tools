@echo off
set /p minutes="Enter the number of minutes until shutdown: "

:: Convert minutes to seconds
set /a seconds=%minutes%*60

:: Schedule shutdown
shutdown /s /t %seconds% /c "System will shut down in %minutes% minutes."
echo System will shut down in %minutes% minutes.