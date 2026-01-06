@echo off
REM ===============================================================
REM  Script: converter_videos.bat
REM  Objetivo: Converter todos os vídeos .mp4 e .avi da pasta atual
REM  - Reduz framerate para 15 fps
REM  - Acelera reprodução em 1.5× (vídeo e áudio)
REM  - Reduz levemente a qualidade (CRF 28)
REM  - Define áudio AAC mono a 128 kbps
REM  - Gera arquivos com o sufixo "_conv.mp4"
REM ===============================================================

for %%f in (*.mp4 *.avi) do (
    echo Convertendo "%%f"...
    ffmpeg -i "%%f" ^
        -filter:v "fps=15,setpts=PTS/1.5" ^
        -filter:a "atempo=1.5" ^
        -crf 28 -preset faster ^
        -c:a aac -b:a 128k -ac 1 ^
        "%%~nf_conv.mp4"
)
echo.
echo Conversao concluida.
pause
