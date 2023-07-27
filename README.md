# Rotate or trim video file using ffmpeg in command line
This repository contains a Windows batch script that allows you to rotate or trim a video using FFmpeg. The script is interactive and prompts the user for input. This script is designed to work on Windows. It uses Windows batch scripting features and will not work on other operating systems.
## Features
1. Rotate a video: The script allows you to rotate a video by 90 degrees in either direction, or flip it vertically.
2. Trim a video: The script also allows you to trim a video by specifying the start and end times of the section you want to keep.
## How to use:
- Double click ffmpeg.bat to open.
- Select from 3 options: rotate, trim, exit.
  ## For rotate:
- Give the video file's path, try not to contain any space in the begining or end of the path.
- Select the rotation that is wanted. By default, if nothing was input, 90 degree CounterCLockwise and Vertical Flip is selected.
- Give the output name, the file is output in the same folder where ffmpeg is, but a different path can be given with the name as well.
  ## For trim:
- Give the video file's path, try not to contain any space in the begining or end of the path.
- Give the start point for trimming, in format of hh:mm:ss, but zero can be omitted, for example, 00:00:01 can be just 1
- Give the end point for trimming, same format as above.
  ## Trick. How to find the path of a file?
 1. Right click on file and select last option "properties", then go to second tab page "security", then copy the path on the page!
 2. A space might be copied with the path, check before you use!
## Dependencies
This script requires FFmpeg to be installed and the executable to be located in the same folder as the script.
## Note
- Download ffmpeg here :https://www.ffmpeg.org/download.html
- Put in ` bin` folder to use.
## Trouble shooting:
- If the output is not generated, check the input path, if it's with space in the begining.
