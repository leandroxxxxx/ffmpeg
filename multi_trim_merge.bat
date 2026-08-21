@echo off
setlocal enabledelayedexpansion

:: Solicita o arquivo de entrada
set /p input_file="Digite ou arraste o caminho do arquivo de vídeo: "
set input_file=%input_file:"=%

:: Extrai a pasta do arquivo de entrada e define a pasta de saída
for %%F in ("!input_file!") do set "input_dir=%%~dpF"
set "output_dir=!input_dir!trimmed video"

:: Cria a pasta de saída caso não exista
if not exist "!output_dir!" mkdir "!output_dir!"

:: Inicializa o contador de trims
set trim_count=0

:collect_trims
set /a trim_count+=1
echo.
echo Trim !trim_count!
set /p start_time="Digite o instante inicial para o trim !trim_count! (formato HH:MM:SS): "
set /p end_time="Digite o instante final para o trim !trim_count! (formato HH:MM:SS): "
set start_time!trim_count!=!start_time!
set end_time!trim_count!=!end_time!
set /p more_trims="Deseja fazer outro trim? (s/n): "
if /i "!more_trims!"=="s" goto collect_trims

:: Solicita o nome do arquivo de saída
set /p output_file="Digite o nome do arquivo final (ex: final_output.mp4): "

:: Garante que o nome tenha a extensão .mp4
echo !output_file! | findstr /i /e "\.mp4" >nul
if errorlevel 1 (
    echo AVISO: extensao ".mp4" nao encontrada no nome informado - ela sera adicionada automaticamente.
    set "output_file=!output_file!.mp4"
)

:: Executa todos os trims
echo Realizando trims...
for /L %%i in (1,1,!trim_count!) do (
    set start_time=!start_time%%i!
    set end_time=!end_time%%i!
    ffmpeg -i "!input_file!" -ss !start_time! -to !end_time! -c:v libx264 -c:a aac "part%%i.mp4"
)

:: Cria um arquivo de lista para mesclagem
echo Criando lista de arquivos para mesclagem...
(echo file 'part1.mp4') > file_list.txt
for /L %%i in (2,1,!trim_count!) do (
    echo file 'part%%i.mp4' >> file_list.txt
)

:: Mescla os trims em um único arquivo, salvando na pasta "trimmed video"
ffmpeg -f concat -safe 0 -i file_list.txt -c copy "!output_dir!\!output_file!"

:: Limpa arquivos temporários
del file_list.txt
for /L %%i in (1,1,!trim_count!) do (
    del part%%i.mp4
)

echo.
echo Processo concluído! Arquivo final salvo em: !output_dir!\!output_file!
pause