@echo off
setlocal enabledelayedexpansion

:begin
cls
set "filepath="
set "outputname=output.mp4"
set "start=00:00:00"
set "end="
set "option="
set "angle="
set "imagepath="

echo =====================================
echo     MEDIA PROCESSING UTILITY
echo =====================================
echo.
echo Please select an operation:
echo.
echo  1. Rotate video
echo  2. Trim any supported media(audio or video)
echo  3. Convert audio to video
echo  4. Rotate and trim video
echo  5. Exit
echo.
set /p option="Enter your choice (1-5): "

if "!option!"=="5" exit /b

if "!option!"=="1" goto rotate_video
if "!option!"=="2" goto trim_media
if "!option!"=="3" goto audio_to_video
if "!option!"=="4" goto rotate_and_trim

:get_filepath
cls
echo =====================================
echo           FILE SELECTION
echo =====================================
echo.
echo Tips: You can either:
echo  - Paste the path directly
echo  - Paste with quotes
echo  - Drag and drop the file
echo.
echo How to find a file path in Windows:
echo  1. Right-click on the file
echo  2. Select "Properties"
echo  3. Look in the "Security" tab for the full file path
echo.
set /p filepath="Enter file path: "
call :sanitize_path filepath

if "!filepath!"=="" (
    echo [ERROR] Please input a valid path.
    pause
    goto get_filepath
)

if not exist "!filepath!" (
    echo [ERROR] File not found: "!filepath!"
    pause
    goto get_filepath
)

exit /b 0

:rotate_video
call :get_filepath

.\ffmpeg -i "!filepath!" 2>nul | findstr /i "video" >nul
if !errorlevel! neq 0 (
    echo [ERROR] Rotation is only applicable to video files.
    pause
    goto begin
)

echo.
echo =====================================
echo           ROTATION ANGLE
echo =====================================
echo.
echo 0 = 90 CounterCLockwise and Vertical Flip
echo 1 = 90 Clockwise
echo 2 = 90 CounterClockwise
echo 3 = 90 Clockwise and Vertical Flip
echo.
set /p angle="Enter rotation angle (0-3): "

if not "!angle!"=="0" if not "!angle!"=="1" if not "!angle!"=="2" if not "!angle!"=="3" (
    echo [ERROR] Invalid angle. Please enter 0, 1, 2, or 3.
    pause
    goto rotate_video
)

call :getfilename "!filepath!"

:rotation_output_name
echo.
echo =====================================
echo           OUTPUT FILE
echo =====================================
echo.
set /p outputname="Enter output name [!outputname!]: "
if "!outputname!"=="" set "outputname=!outputname!"

call :sanitize_path outputname

echo.
echo =====================================
echo           CONFIRMATION
echo =====================================
echo.
echo Input file : "!filepath!"
echo Angle      : !angle!
echo Output file: "!outputname!"
echo.
echo Is this correct?
echo 1. Yes, proceed with processing
echo 2. No, change output filename
echo 3. Cancel operation
echo.
set /p confirm="Your choice (1-3): "

if "!confirm!"=="2" goto rotation_output_name
if "!confirm!"=="3" goto begin
if not "!confirm!"=="1" (
    echo [ERROR] Invalid choice. Please try again.
    pause
    goto rotation_output_name
)

echo.
echo =====================================
echo           PROCESSING
echo =====================================
echo.

.\ffmpeg -i "!filepath!" -vf "transpose=!angle!" -c:a copy "!outputname!"

if !errorlevel! equ 0 (
    echo.
    echo =====================================
    echo [SUCCESS] Process complete!
    echo Output saved as: "!outputname!"
    echo =====================================
) else (
    echo.
    echo =====================================
    echo [ERROR] FFmpeg reported an error
    echo Please check the output above
    echo =====================================
)
pause
goto begin

:trim_media
call :get_filepath

echo.
echo =====================================
echo           TIME SELECTION
echo =====================================
echo Format: hh:mm:ss (example: 00:01:30)
echo         or mm:ss (example: 01:30)
echo         or just seconds (example: 90)
echo.
set /p start="Enter start time (default: 00:00:00): "
if "!start!"=="" set "start=00:00:00"

set /p end="Enter end time (default: end of media): "

call :validate_time start
call :validate_time end

call :getfilename "!filepath!"

:trimming_output_name
echo.
echo =====================================
echo           OUTPUT FILE
echo =====================================
echo.
set /p outputname="Enter output name [!outputname!]: "
if "!outputname!"=="" set "outputname=!outputname!"

call :sanitize_path outputname

echo.
echo =====================================
echo           CONFIRMATION
echo =====================================
echo.
echo Input file : "!filepath!"
echo Start time : !start!
if "!end!"=="" (
    echo End time   : Default (end of media)
) else (
    echo End time   : !end!
)
echo Output file: "!outputname!"
echo.
echo Is this correct?
echo 1. Yes, proceed with processing
echo 2. No, change output filename
echo 3. Cancel operation
echo.
set /p confirm="Your choice (1-3): "

if "!confirm!"=="2" goto trimming_output_name
if "!confirm!"=="3" goto begin
if not "!confirm!"=="1" (
    echo [ERROR] Invalid choice. Please try again.
    pause
    goto trimming_output_name
)

echo.
echo =====================================
echo           PROCESSING
echo =====================================
echo.

if "!end!"=="" (
    .\ffmpeg -i "!filepath!" -ss !start! -c copy "!outputname!"
) else (
    .\ffmpeg -i "!filepath!" -ss !start! -to !end! -c copy "!outputname!"
)

if !errorlevel! equ 0 (
    echo.
    echo =====================================
    echo [SUCCESS] Process complete!
    echo Output saved as: "!outputname!"
    echo =====================================
) else (
    echo.
    echo =====================================
    echo [ERROR] FFmpeg reported an error
    echo Please check the output above
    echo =====================================
)
pause
goto begin

:audio_to_video
:input_path3
cls
echo =====================================
echo       AUDIO TO VIDEO CONVERSION
echo =====================================
echo.
echo Tips: You can either:
echo  - Paste the path directly
echo  - Paste with quotes
echo  - Drag and drop the file
echo.
echo How to find a file path in Windows:
echo  1. Right-click on the file
echo  2. Select "Properties"
echo  3. Look in the "Security" tab for the full file path
echo.
set /p filepath="Enter audio file path: "
call :sanitize_path filepath

if "!filepath!"=="" (
    echo [ERROR] Please input a valid audio path.
    pause
    goto input_path3
)

if not exist "!filepath!" (
    echo [ERROR] Audio file not found: "!filepath!"
    pause
    goto input_path3
)

set /p imagepath="Enter image file path: "
call :sanitize_path imagepath

if "!imagepath!"=="" (
    echo [ERROR] Please input a valid image path.
    pause
    goto input_path3
)

if not exist "!imagepath!" (
    echo [ERROR] Image file not found: "!imagepath!"
    pause
    goto input_path3
)

call :getfilename "!filepath!"
set "outputname=!outputname!.mp4"

:audio_to_video_output_name
echo.
echo =====================================
echo           OUTPUT FILE
echo =====================================
echo.
set /p outputname="Enter output name [!outputname!]: "
if "!outputname!"=="" set "outputname=!outputname!"

call :sanitize_path outputname

echo.
echo =====================================
echo           CONFIRMATION
echo =====================================
echo.
echo Audio file : "!filepath!"
echo Image file : "!imagepath!"
echo Output file: "!outputname!"
echo.
echo Is this correct?
echo 1. Yes, proceed with processing
echo 2. No, change output filename
echo 3. Cancel operation
echo.
set /p confirm="Your choice (1-3): "

if "!confirm!"=="2" goto audio_to_video_output_name
if "!confirm!"=="3" goto begin
if not "!confirm!"=="1" (
    echo [ERROR] Invalid choice. Please try again.
    pause
    goto audio_to_video_output_name
)

echo.
echo =====================================
echo           PROCESSING
echo =====================================
echo.

.\ffmpeg -loop 1 -i "!imagepath!" -i "!filepath!" -c:v libx264 -tune stillimage -c:a copy -pix_fmt yuv420p -shortest "!outputname!"

if !errorlevel! equ 0 (
    echo.
    echo =====================================
    echo [SUCCESS] Process complete!
    echo Output saved as: "!outputname!"
    echo =====================================
) else (
    echo.
    echo =====================================
    echo [ERROR] FFmpeg reported an error
    echo Please check the output above
    echo =====================================
)
pause
goto begin

:rotate_and_trim
call :get_filepath

.\ffmpeg -i "!filepath!" 2>nul | findstr /i "video" >nul
if !errorlevel! neq 0 (
    echo [ERROR] Rotate and trim is only applicable to video files.
    pause
    goto begin
)

echo.
echo =====================================
echo           ROTATION ANGLE
echo =====================================
echo.
echo 0 = 90 CounterCLockwise and Vertical Flip
echo 1 = 90 Clockwise
echo 2 = 90 CounterClockwise
echo 3 = 90 Clockwise and Vertical Flip
echo.
set /p angle="Enter rotation angle (0-3): "

if not "!angle!"=="0" if not "!angle!"=="1" if not "!angle!"=="2" if not "!angle!"=="3" (
    echo [ERROR] Invalid angle. Please enter 0, 1, 2, or 3.
    pause
    goto rotate_and_trim
)

echo.
echo =====================================
echo           TIME SELECTION
echo =====================================
echo Format: hh:mm:ss (example: 00:01:30)
echo         or mm:ss (example: 01:30)
echo         or just seconds (example: 90)
echo.
set /p start="Enter start time (default: 00:00:00): "
if "!start!"=="" set "start=00:00:00"

set /p end="Enter end time (default: end of video): "

call :validate_time start
call :validate_time end

call :getfilename "!filepath!"

:rotate_trim_output_name
echo.
echo =====================================
echo           OUTPUT FILE
echo =====================================
echo.
set /p outputname="Enter output name [!outputname!]: "
if "!outputname!"=="" set "outputname=!outputname!"

call :sanitize_path outputname

echo.
echo =====================================
echo           CONFIRMATION
echo =====================================
echo.
echo Input file : "!filepath!"
echo Angle      : !angle!
echo Start time : !start!
if "!end!"=="" (
    echo End time   : Default (end of video)
) else (
    echo End time   : !end!
)
echo Output file: "!outputname!"
echo.
echo Is this correct?
echo 1. Yes, proceed with processing
echo 2. No, change output filename
echo 3. Cancel operation
echo.
set /p confirm="Your choice (1-3): "

if "!confirm!"=="2" goto rotate_trim_output_name
if "!confirm!"=="3" goto begin
if not "!confirm!"=="1" (
    echo [ERROR] Invalid choice. Please try again.
    pause
    goto rotate_trim_output_name
)

echo.
echo =====================================
echo           PROCESSING
echo =====================================
echo.

if "!end!"=="" (
    .\ffmpeg -i "!filepath!" -ss !start! -vf "transpose=!angle!" -c:a copy "!outputname!"
) else (
    .\ffmpeg -i "!filepath!" -ss !start! -to !end! -vf "transpose=!angle!" -c:a copy "!outputname!"
)

if !errorlevel! equ 0 (
    echo.
    echo =====================================
    echo [SUCCESS] Process complete!
    echo Output saved as: "!outputname!"
    echo =====================================
) else (
    echo.
    echo =====================================
    echo [ERROR] FFmpeg reported an error
    echo Please check the output above
    echo =====================================
)
pause
goto begin

:getfilename
set "outputname=%~nx1"
goto :eof

:sanitize_path
set "var=!%1!"
set "var=!var:"=!"
for /f "tokens=* delims= " %%a in ("!var!") do set "var=%%a"
for /l %%a in (1,1,100) do if "!var:~-1!"==" " set "var=!var:~0,-1!"
set "%1=!var!"
goto :eof

:validate_time
set "time=!%1!"
if "!time!"=="" goto :eof
if "!time:~2,1!"==":" if "!time:~5,1!"==":" (
    rem Valid hh:mm:ss format
    goto :eof
)
if "!time:~1,1!"==":" (
    rem Valid m:ss format
    goto :eof
)
if "!time!" geq "0" 2>nul (
    rem Valid seconds format
    goto :eof
)
echo [ERROR] Invalid time format. Please use hh:mm:ss, m:ss, or seconds.
pause
goto begin
