@echo off
title FFmpeg - Extrair Frames (Versao Blindada)
:: Força o terminal a entender acentos (UTF-8)
chcp 65001 >nul

echo ================================================
echo FFmpeg - Extrair Frames (Suporte a Acentos e Virgulas)
echo ================================================

:: 1. Solicitação do Arquivo
echo Arraste o arquivo de video para esta janela:
set /p input="Arquivo: "
set "input=%input:"=%"

if not exist "%input%" (
    echo.
    echo ERRO: Arquivo nao encontrado. Verifique o caminho.
    pause
    exit
)

:: 2. Solicitação dos Tempos
echo.
set /p start_time="Tempo inicial (formato HH:MM:SS ou SS): "
set /p end_time="Tempo final (formato HH:MM:SS ou SS): "

:: 3. Pergunta sobre o nome
echo.
set /p change_name="Deseja alterar o nome base? (s/n): "
if /i "%change_name%"=="s" (
    set /p frame_name="Digite o nome base: "
) else (
    for %%A in ("%input%") do set "frame_name=%%~nA"
)

:: 4. Execução via PowerShell (Lida com FPS com virgula, acentos e calculos)
echo.
echo Processando... Por favor, aguarde.
echo (Isso pode levar alguns segundos dependendo da duracao)

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$inputVideo = '%input%';" ^
    "$startStr = '%start_time%';" ^
    "$endStr = '%end_time%';" ^
    "$baseName = '%frame_name%';" ^
    "$outDir = Join-Path (Split-Path $inputVideo) ('frames_' + $baseName);" ^
    "if (!(Test-Path $outDir)) { New-Item $outDir -ItemType Directory | Out-Null };" ^
    "$rawFps = (ffprobe -v 0 -of csv=p=0 -select_streams v:0 -show_entries stream=r_frame_rate $inputVideo);" ^
    "$fps = Invoke-Expression $rawFps.Replace(',','.');" ^
    "if ($startStr -match ':') { $s = [TimeSpan]::Parse($startStr).TotalSeconds } else { $s = [double]$startStr };" ^
    "if ($endStr -match ':') { $e = [TimeSpan]::Parse($endStr).TotalSeconds } else { $e = [double]$endStr };" ^
    "$dur = $e - $s;" ^
    "$startFrame = [math]::Floor($s * $fps);" ^
    "$tempPattern = Join-Path $outDir 'temp_%%06d.jpg';" ^
    "& ffmpeg -v error -ss $startStr -i $inputVideo -t $dur -vsync vfr -start_number $startFrame -q:v 2 $tempPattern;" ^
    "$files = Get-ChildItem -LiteralPath $outDir -Filter 'temp_*.jpg';" ^
    "foreach ($f in $files) {" ^
    "    if ($f.Name -match 'temp_(\d+)\.jpg') {" ^
    "        $num = [int]$matches[1];" ^
    "        $time = ($num / $fps);" ^
    "        $timeStr = $time.ToString('0.000', [System.Globalization.CultureInfo]::InvariantCulture);" ^
    "        $newName = $baseName + '_' + $timeStr + 's_' + $num + '.jpg';" ^
    "        $target = Join-Path $f.DirectoryName $newName;" ^
    "        if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target };" ^
    "        Rename-Item -LiteralPath $f.FullName -NewName $newName;" ^
    "    }" ^
    "}"

if %errorlevel% neq 0 (
    echo.
    echo Ocorreu um erro durante o processamento.
) else (
    echo.
    echo ================================================
    echo SUCESSO! Frames extraidos e renomeados.
    echo Verifique a pasta do video original.
    echo ================================================
)
pause