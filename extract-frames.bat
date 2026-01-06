@echo off
title FFmpeg - Extrair Frames (3 Casas Decimais)
setlocal enabledelayedexpansion

:: ================================================
:: CONFIGURAÇÃO INICIAL
:: ================================================
echo ================================================
echo FFmpeg - Extrair Frames (Tempo .000s + Numeracao)
echo ================================================

:: Verifica se o ffprobe existe
where ffprobe >nul 2>nul
if %errorlevel% neq 0 (
    echo ERRO: O 'ffprobe.exe' nao foi encontrado.
    pause
    exit
)

:: Solicitação do Input
echo Arraste o arquivo de video para esta janela:
set /p input="Arquivo: "
set "input=%input:"=%"

if not exist "%input%" (
    echo ERRO: Arquivo nao encontrado.
    pause
    exit
)

:: 1. Obter o FPS original (converte frações para decimal)
for /f "tokens=*" %%i in ('powershell -command "$raw = (ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate '%input%'); $val = Invoke-Expression $raw; [math]::Round($val, 3)"') do set "fps=%%i"

echo FPS Detectado: %fps%

:: Solicitação dos Tempos
echo.
set /p start_time="Tempo inicial (ex: 00:00:10 ou 10): "
set /p end_time="Tempo final (ex: 00:00:15 ou 15): "

:: Pergunta sobre o nome dos frames
echo.
set /p change_name="Deseja alterar o nome base dos frames? (s/n): "
if /i "%change_name%"=="s" (
    set /p frame_name="Digite o nome base: "
) else (
    for %%A in ("%input%") do set "frame_name=%%~nA"
)

:: ================================================
:: CÁLCULOS DE DURAÇÃO E FRAME INICIAL
:: ================================================
(
echo $s_str = '%start_time%'
echo $e_str = '%end_time%'
echo $fps = %fps%
echo if ^($s_str -match ':'^) { $s = [TimeSpan]::Parse^($s_str^).TotalSeconds } else { $s = [double]$s_str }
echo if ^($e_str -match ':'^) { $e = [TimeSpan]::Parse^($e_str^).TotalSeconds } else { $e = [double]$e_str }
echo $dur = $e - $s
echo $frame = [math]::Floor^($s * $fps^)
echo $dur_str = $dur.ToString^('0.000', [System.Globalization.CultureInfo]::InvariantCulture^)
echo Write-Output "$frame $dur_str"
) > temp_calc.ps1

for /f "usebackq tokens=1,2" %%A in (`powershell -ExecutionPolicy Bypass -File temp_calc.ps1`) do (
    set "start_number=%%A"
    set "duration=%%B"
)
del temp_calc.ps1

:: ================================================
:: DEFINIÇÃO DA PASTA DE SAÍDA (Pasta do Vídeo)
:: ================================================
for %%A in ("%input%") do set "video_folder=%%~dpA"
set "output_dir=!video_folder!frames_!frame_name!"

if not exist "%output_dir%" mkdir "%output_dir%"

:: ================================================
:: PROCESSAMENTO
:: ================================================

echo.
echo Extraindo frames para: "%output_dir%"
:: Extrai com nome temporario (temp_000001.jpg) para renomear em seguida
ffmpeg -v error -ss %start_time% -i "%input%" -t !duration! -vsync vfr -start_number !start_number! -q:v 2 "%output_dir%\temp_%%06d.jpg"

echo Renomeando arquivos com 3 casas decimais...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$files = Get-ChildItem '%output_dir%\temp_*.jpg';" ^
    "$fps = [double]%fps%;" ^
    "foreach ($f in $files) {" ^
    "    if ($f.Name -match 'temp_(\d+)\.jpg') {" ^
    "        $num = [int]$matches[1];" ^
    "        $time = ($num / $fps);" ^
    "        $timeStr = $time.ToString('0.000', [System.Globalization.CultureInfo]::InvariantCulture);" ^
    "        $newName = '%frame_name%_' + $timeStr + 's_' + $num + '.jpg';" ^
    "        if (Test-Path \"$($f.DirectoryName)\$newName\") { Remove-Item \"$($f.DirectoryName)\$newName\" };" ^
    "        Rename-Item $f.FullName -NewName $newName" ^
    "    }" ^
    "}"

echo.
echo ================================================
echo CONCLUIDO!
echo Exemplo de arquivo: %frame_name%_1.125s_37.jpg
echo Pasta: "%output_dir%"
echo ================================================
pause