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
    set /p filepath="Please enter the file path of the video you want to trim: "
    if !filepath!=="" (
        echo "Please input the right path for the video."
        goto input_path2
    )
    set /p start="Please enter the start time (in hh:mm:ss) of the section you want to keep: "
    set /p end="Please enter the end time (in hh:mm:ss) of the section you want to keep: "
    call :getfilename "!filepath!"
    set /p outputname="Please enter the output file name or path (default is !outputname!): "
    .\ffmpeg -i "!filepath!" -ss !start! -to !end! -c copy "!outputname!"
    timeout /t -1
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