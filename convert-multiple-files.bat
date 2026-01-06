@echo off
setlocal enabledelayedexpansion

:: Solicita ao usuário o diretório onde os arquivos estão localizados
set /p "input_folder=Arraste a pasta com os arquivos aqui e pressione Enter: "

:: Remove aspas extras caso o usuário arraste a pasta
set input_folder=%input_folder:"=%

:: Verifica se a pasta existe
if not exist "%input_folder%" (
    echo ERRO: A pasta especificada nao existe.
    pause
    exit /b
)

:: Solicita a extensão de saída
set /p "output_ext=Digite a extensao de saida (exemplo: wav, mp3, flac): "

:: Processa todos os arquivos da pasta
for %%i in ("%input_folder%\*.*") do (
    ffmpeg -i "%%i" "%input_folder%\%%~ni.%output_ext%"
)

echo Conversao concluida!
pause
