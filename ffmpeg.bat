@echo off
rem the windows batch script does not allow multiple instructions under if statement, enable this will make it possible
setlocal enabledelayedexpansion
rem put the whole code in a loop, this is the start of the loop
:begin
rem clear the screen
cls
rem clear all the data
set "filepath="""
rem has to set filepath to empty here, otherwise it's not empty somehow, maybe it's null by default
set "outputname="
set "start="
set "end="
set "option="
set "angle="
rem set /p option="Do you want to rotate or trim a video? Enter 1 for rotate, 2 for trim, 3 for exit: "
set /p option="Do you want to rotate, trim a video, convert audio to video or exit? Enter 1 for rotate, 2 for trim, 3 for audio to video, 4 for exit: "
if "!option!"=="1" (
    :input_path1
    set /p filepath="Please enter the file path of the video you want to rotate: "
    ::need to check if user input anything for the input file path, if not, go back to ask again
    if !filepath!=="" (
        echo:
        echo "Please input the right path for the video."
        goto input_path1
    )
    rem to put a new line here
    echo:
    echo "Your file is !filepath!"
    set /p "angle=Please enter the rotation angle (0 = 90 CounterCLockwise and Vertical Flip, 1 = 90 Clockwise, 2 = 90 CounterClockwise, 3 = 90 Clockwise and Vertical Flip): "
    rem I have to use rem for comment, using :: is causing the system having error for unknow reason
    rem echo !angle!
    rem echo !filepath!
    rem this calls a function to pass the input file name to the default output file.
    rem the quotation mark is important otherwise file name cannot have any space in it.
    call :getfilename "!filepath!"
    set /p "outputname=Please enter the output file name or path (default is !outputname!): "
    echo "Your outputname is !outputname!"
    rem this is for debug use
    rem echo .\ffmpeg -i "!filepath!" -vf "transpose=!angle!" "!outputname!"
    .\ffmpeg -i "!filepath!" -vf "transpose=!angle!" "!outputname!"
    timeout /t -1
)
if "!option!"=="2" (
    :input_path2
    cls
    echo =====================================
    echo           VIDEO TRIMMING
    echo =====================================
    echo.
    echo Tips: You can either:
    echo  - Paste the path directly
    echo  - Paste with quotes
    echo  - Drag and drop the file
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
        goto input_path2
    )
    
    echo.
    echo Checking file...
    if exist "!filepath!" (
        echo [SUCCESS] File found: "!filepath!"
    ) else (
        echo [ERROR] File not found: "!filepath!"
        echo Press any key to try again...
        pause > nul
        goto input_path2
    )
    
    echo.
    echo =====================================
    echo           TIME SELECTION
    echo =====================================
    echo Format: hh:mm:ss (example: 00:01:30)
    echo         or just seconds (example: 90)
    echo.
    set /p start="Enter start time: "
    set /p end="Enter end time  : "
    
    call :getfilename "!filepath!"
    if "!outputname!"=="" set "outputname=output.mp4"
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
    echo Start time : !start!
    echo End time   : !end!
    echo Output file: "!outputname!"
    echo.
    echo Press [Enter] to start processing
    echo Press [Ctrl+C] to cancel
    pause > nul
    
    echo.
    echo =====================================
    echo           PROCESSING
    echo =====================================
    echo.
    
    .\ffmpeg -i "!filepath!" -ss !start! -to !end! -c copy "!outputname!"
    
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
)
if "!option!"=="3" (
    :input_path3
    set /p filepath="Please enter the file path of the audio you want to convert: "
    if !filepath!=="" (
        echo "Please input the right path for the audio."
        goto input_path3
    )
    set /p imagepath="Please enter the file path of the image you want to use: "
    if !imagepath!=="" (
        echo "Please input the right path for the image."
        goto input_path3
    )
    call :getfilename "!filepath!"
    set /p outputname="Please enter the output file name or path (default is !outputname!.mp4): "
    .\ffmpeg -loop 1 -i "!imagepath!" -i "!filepath!" -c:v libx264 -tune stillimage -c:a copy -b:a 192k -pix_fmt yuv420p -shortest "!outputname!"
    rem this code makes the ffmpeg keep the audio codec and the video has same duration as audio file
    timeout /t -1
)
if "!option!"=="4" (
    exit
)
goto begin

rem The ~nx modifier is used to extract the filename and extension from a file path variable. 
rem However, it only works directly on variables that are parameters to a script or function, not on arbitrary variables.
rem The 1 here means the first arguement that passed in, which is !filepath!.
:getfilename
set "outputname=%~nx1"
goto :eof