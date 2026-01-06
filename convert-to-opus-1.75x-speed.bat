@echo off
for %%f in (*.mp3 *.aac) do ffmpeg -i "%%f" -filter:a "atempo=1.75" -b:a 18k -ar 16000 -ac 1 "%%~nf.opus"
pause

