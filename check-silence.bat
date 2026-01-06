@echo off
title FFmpeg - Encontrar Silencios
setlocal enabledelayedexpansion

:: Solicitação do Input
echo ================================================
echo FFmpeg - Verifica os silencios encontrados no Áudio
echo ================================================
echo Arraste o arquivo de entrada para esta janela ou digite o caminho completo:
set /p input="Arquivo de entrada: "

:: Remover aspas extras do caminho
set "input=%input:"=%"

:: Verifica se o arquivo existe
if not exist "%input%" (
    echo ERRO: O arquivo especificado nao existe. Tente novamente.
    pause
    exit
)


:: Comando FFmpeg
echo.
echo Processando... Por favor, aguarde.
ffmpeg -i "%input%" -af silencedetect=n=-30dB:d=0.5 -f null -

:: Finalização
echo.
echo Pressione qualquer tecla para fechar esta janela...
pause >nul
