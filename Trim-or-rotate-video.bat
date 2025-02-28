@echo off
rem the windows batch script does not allow multiple instructions under if statement, enable this will make it possible
setlocal enabledelayedexpansion
rem put the whole code in a loop, this is the start of the loop
:begin
rem clear the screen
cls
rem clear all the data
set "filepath="
rem has to set filepath to empty here, otherwise it's not empty somehow, maybe it's null by default
set "outputname="
set "start="
set "end="
set "option="
set "angle="

echo =====================================
echo     VIDEO PROCESSING UTILITY
echo =====================================
echo.
echo Please select an operation:
echo.
echo  1. Rotate video
echo  2. Trim video
echo  3. Convert audio to video
echo  4. Rotate and trim video
echo  5. Exit
echo.
set /p option="Enter your choice (1-5): "

if "!option!"=="5" (
    exit /b
)

if "!option!"=="1" goto rotate_video
if "!option!"=="2" goto trim_video
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
echo  3. Look in the "Security" tab
echo.
set /p filepath="Enter video file path: "
rem Remove surrounding quotes if present
set "filepath=!filepath:"=!"
rem Remove leading/trailing spaces
for /f "tokens=* delims= " %%a in ("!filepath!") do set "filepath=%%a"
for /l %%a in (1,1,100) do if "!filepath:~-1!"==" " set "filepath=!filepath:~0,-1!"

if "!filepath!"=="" (
    echo [ERROR] Please input a valid path.
    echo Press any key to try again...
    pause > nul
    goto get_filepath
)

echo.
echo Checking file...
if exist "!filepath!" (
    echo [SUCCESS] File found: "!filepath!"
) else (
    echo [ERROR] File not found: "!filepath!"
    echo Press any key to try again...
    pause > nul
    goto get_filepath
)
exit /b 0

:rotate_video
call :get_filepath
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

call :getfilename "!filepath!"

:rotation_output_name
echo.
echo =====================================
echo           OUTPUT FILE
echo =====================================
echo.
set /p outputname="Enter output name [!outputname!]: "
rem Handle output name the same way as input
set "outputname=!outputname:"=!"
for /f "tokens=* delims= " %%a in ("!outputname!") do set "outputname=%%a"
for /l %%a in (1,1,100) do if "!outputname:~-1!"==" " set "outputname=!outputname:~0,-1!"
if "!outputname!"=="" call :getfilename "!filepath!"

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
    goto :rotation_output_name
)

echo.
echo =====================================
echo           PROCESSING
echo =====================================
echo.

rem Updated command to preserve video and audio codecs
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
echo.
pause
goto begin

:trim_video
call :get_filepath

echo.
echo =====================================
echo           TIME SELECTION
echo =====================================
echo Format: hh:mm:ss (example: 00:01:30)
echo         or just seconds (example: 90)
echo.
echo Press Enter for default start time (00:00:00)
set /p start="Enter start time: "
if "!start!"=="" set "start=00:00:00"

echo.
echo Press Enter for default end time (end of video)
set /p end="Enter end time  : "

call :getfilename "!filepath!"
if "!outputname!"=="" set "outputname=output.mp4"

:trimming_output_name
echo.
echo =====================================
echo           OUTPUT FILE
echo =====================================
echo.
set /p outputname="Enter output name [!outputname!]: "
rem Handle output name the same way as input
set "outputname=!outputname:"=!"
for /f "tokens=* delims= " %%a in ("!outputname!") do set "outputname=%%a"
for /l %%a in (1,1,100) do if "!outputname:~-1!"==" " set "outputname=!outputname:~0,-1!"
if "!outputname!"=="" set "outputname=output.mp4"

echo.
echo =====================================
echo           CONFIRMATION
echo =====================================
echo.
echo Input file : "!filepath!"
if "!start!"=="" (
    echo Start time : Default (beginning)
) else (
    echo Start time : !start!
)
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

if "!confirm!"=="2" goto trimming_output_name
if "!confirm!"=="3" goto begin
if not "!confirm!"=="1" (
    echo [ERROR] Invalid choice. Please try again.
    pause
    goto :trimming_output_name
)

echo.
echo =====================================
echo           PROCESSING
echo =====================================
echo.

rem Command handling with empty end time (use whole video)
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
echo.
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
echo  3. Look in the "Security" tab
echo.
set /p filepath="Enter audio file path: "
rem Remove surrounding quotes if present
set "filepath=!filepath:"=!"
rem Remove leading/trailing spaces
for /f "tokens=* delims= " %%a in ("!filepath!") do set "filepath=%%a"
for /l %%a in (1,1,100) do if "!filepath:~-1!"==" " set "filepath=!filepath:~0,-1!"

if "!filepath!"=="" (
    echo [ERROR] Please input a valid audio path.
    echo Press any key to try again...
    pause > nul
    goto input_path3
)

echo.
echo Checking audio file...
if exist "!filepath!" (
    echo [SUCCESS] Audio file found: "!filepath!"
) else (
    echo [ERROR] Audio file not found: "!filepath!"
    echo Press any key to try again...
    pause > nul
    goto input_path3
)

echo.
echo How to find a file path in Windows:
echo  1. Right-click on the file
echo  2. Select "Properties"
echo  3. Look in the "Security" tab
echo.
set /p imagepath="Enter image file path: "
rem Remove surrounding quotes if present
set "imagepath=!imagepath:"=!"
rem Remove leading/trailing spaces
for /f "tokens=* delims= " %%a in ("!imagepath!") do set "imagepath=%%a"
for /l %%a in (1,1,100) do if "!imagepath:~-1!"==" " set "imagepath=!imagepath:~0,-1!"

if "!imagepath!"=="" (
    echo [ERROR] Please input a valid image path.
    echo Press any key to try again...
    pause > nul
    goto input_path3
)

echo.
echo Checking image file...
if exist "!imagepath!" (
    echo [SUCCESS] Image file found: "!imagepath!"
) else (
    echo [ERROR] Image file not found: "!imagepath!"
    echo Press any key to try again...
    pause > nul
    goto input_path3
)

call :getfilename "!filepath!"

:audio_to_video_output_name
echo.
echo =====================================
echo           OUTPUT FILE
echo =====================================
echo.
set /p outputname="Enter output name [!outputname!.mp4]: "
if "!outputname!"=="" (
    call :getfilename "!filepath!"
    set "outputname=!outputname!.mp4"
)

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
    goto :audio_to_video_output_name
)

echo.
echo =====================================
echo           PROCESSING
echo =====================================
echo.

rem Removed -b:a 192k to fully preserve audio codec and quality
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
echo.
pause
goto begin

:rotate_and_trim
call :get_filepath

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

echo.
echo =====================================
echo           TIME SELECTION
echo =====================================
echo Format: hh:mm:ss (example: 00:01:30)
echo         or just seconds (example: 90)
echo.
echo Press Enter for default start time (00:00:00)
set /p start="Enter start time: "
if "!start!"=="" set "start=00:00:00"

echo.
echo Press Enter for default end time (end of video)
set /p end="Enter end time  : "

call :getfilename "!filepath!"
if "!outputname!"=="" set "outputname=output.mp4"

:rotate_trim_output_name
echo.
echo =====================================
echo           OUTPUT FILE
echo =====================================
echo.
set /p outputname="Enter output name [!outputname!]: "
rem Handle output name the same way as input
set "outputname=!outputname:"=!"
for /f "tokens=* delims= " %%a in ("!outputname!") do set "outputname=%%a"
for /l %%a in (1,1,100) do if "!outputname:~-1!"==" " set "outputname=!outputname:~0,-1!"
if "!outputname!"=="" set "outputname=output.mp4"

echo.
echo =====================================
echo           CONFIRMATION
echo =====================================
echo.
echo Input file : "!filepath!"
echo Angle      : !angle!
if "!start!"=="" (
    echo Start time : Default (beginning)
) else (
    echo Start time : !start!
)
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
    goto :rotate_trim_output_name
)

echo.
echo =====================================
echo           PROCESSING
echo =====================================
echo.

rem Handle different command combinations based on whether end time is specified
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
echo.
pause
goto begin

rem The ~nx modifier is used to extract the filename and extension from a file path variable. 
rem However, it only works directly on variables that are parameters to a script or function, not on arbitrary variables.
rem The 1 here means the first arguement that passed in, which is !filepath!.
:getfilename
set "outputname=%~nx1"
goto :eof