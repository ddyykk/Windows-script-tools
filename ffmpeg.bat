@echo off
setlocal enabledelayedexpansion
:begin
cls
::clear all the data
set "filepath="""
set "outputname="
set "start="
set "end="
set "option="
set "angle="
set /p option="Do you want to rotate or trim a video? Enter 1 for rotate, 2 for trim, 3 for exit: "

if "!option!"=="1" (
    :input_path1
    set /p filepath="Please enter the file path of the video you want to rotate: "
    if !filepath!=="" (
        echo:
        echo "Please input the right path for the video."
        goto input_path1
    )
    echo:
    echo "Your file is !filepath!"
    set /p "angle=Please enter the rotation angle (0 = 90CounterCLockwise and Vertical Flip, 1 = 90Clockwise, 2 = 90CounterClockwise, 3 = 90Clockwise and Vertical Flip): "
    echo !angle!
    call :getfilename "!filepath!"
    set /p "outputname=Please enter the output file name or path (default is !outputname!): "
    echo "Your outputname is !outputname!"
    ::echo .\ffmpeg -i "!filepath!" -vf "transpose=!angle!" "!outputname!"
    .\ffmpeg -i "!filepath!" -vf "transpose=!angle!" "!outputname!"
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
)
if "!option!"=="3" (
    exit
)
goto begin

:getfilename
set "outputname=%~nx1"
goto :eof