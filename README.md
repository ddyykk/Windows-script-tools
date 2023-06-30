# Rotate or trim video file using ffmpeg in command line
- ffmpeg.bat works for windows only.
- Must put in the folder that has ffmpeg.exe in it.
- download ffmpeg here :https://www.ffmpeg.org/download.html
- put in ` bin` folder to use.


## How to use:
- double click to open
- select from 3 options: rotate, trim, exit.
  ## for rotate:
- give the video file's path, try not to contain any space in the begining or end of the path.
- select the rotation that is wanted. By default, if nothing was input, 90 degree CounterCLockwise and Vertical Flip is selected.
- give the output name, the file is output in the same folder where ffmpeg is, but a different path can be given with the name as well.
  ## for trim:
- give the video file's path, try not to contain any space in the begining or end of the path.
- give the start point for trimming, in format of hh:mm:ss, but zero can be omitted, for example, 00:00:01 can be just 1
- give the end point for trimming, same format as above.

## trouble shooting:
- if the output is not generated, check the input path, if it's with space in the begining.
