@echo off
title FFmpeg - Remover Silencio
setlocal enabledelayedexpansion

:: Solicitação do Input
echo ================================================
echo FFmpeg - Remover Silencio do Arquivo de Audio
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

:: Solicitação do Output
echo.
set /p output="Digite o nome do arquivo de saida (com extensao, ex: output.mp3): "

:: Caminho do Output (mesma pasta do Input)
for %%A in ("%input%") do set "output_path=%%~dpA%output%"

:: Comando FFmpeg
echo.
echo Processando... Por favor, aguarde.
ffmpeg -i "%input%" -af silenceremove=start_periods=1:start_duration=0.1:start_threshold=-30dB:stop_periods=-1:stop_duration=0.1:stop_threshold=-30dB "%output_path%"

:: Mensagem de Sucesso
if exist "%output_path%" (
    echo.
    echo SUCESSO: O arquivo "%output%" foi criado na mesma pasta do arquivo de entrada.
) else (
    echo ERRO: Ocorreu um problema durante o processamento.
)

:: Finalização
echo.
echo Pressione qualquer tecla para fechar esta janela...
pause >nul
