@echo off
@rem
@rem build.bat
@rem Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
@rem

setlocal enabledelayedexpansion

set APP_NAME=react_template

rem 時間計測フラグと--no-cacheフラグを初期化
set measure_time=0
set no_cache=

rem 引数をチェック
:parse_args
if "%1"=="/T" (
    set measure_time=1
    echo 時間計測を開始します。
    shift
    goto parse_args
)
if "%1"=="/NC" (
    set no_cache=--no-cache
    echo --no-cacheオプションを使用します。
    shift
    goto parse_args
)
if not "%1"=="" (
    echo 不明な引数: %1
    exit /b 1
)

rem 時間計測が有効な場合、開始時刻を記録
if %measure_time%==1 (
    for /f "tokens=1-4 delims=:.," %%a in ("!time!") do (
        set /a "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
    )
)

rem <none>タグのイメージを削除
echo none タグのイメージを削除します...
docker compose -f docker-compose-%STAGE%.yaml down --remove-orphans
echo y | docker image prune

cd ../../../
cd
set /p APP_VERSION=<./src/.app-version
set /p NODE_VERSION=<./src/.node-version

echo ◆◆◆◆◆ イメージをビルドします。 ◆◆◆◆◆
echo - タグ: %APP_VERSION%
echo - Node.jsバージョン: %NODE_VERSION%
rem BuildKitを有効にし、進捗を表示
set DOCKER_BUILDKIT=1
if %measure_time%==1 (
    docker compose -f docker-compose-%STAGE%.yaml build %no_cache% --progress=plain
) else (
    docker compose -f docker-compose-%STAGE%.yaml build %no_cache%
)

cd docker-config/launcher/prep

rem 時間計測が有効な場合、終了時刻を記録し実行時間を計算
if %measure_time%==1 (
    for /f "tokens=1-4 delims=:.," %%a in ("!time!") do (
        set /a "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
    )
    set /a "elapsed=end-start"
    set /a "hh=elapsed/(60*60*100)"
    set /a "rest=elapsed%%(60*60*100)"
    set /a "mm=rest/(60*100)"
    set /a "rest=rest%%(60*100)"
    set /a "ss=rest/100"
    set /a "cc=rest%%100"
    if !hh! lss 10 set "hh=0!hh!"
    if !mm! lss 10 set "mm=0!mm!"
    if !ss! lss 10 set "ss=0!ss!"
    if !cc! lss 10 set "cc=0!cc!"
    echo 総実行時間: !hh!:!mm!:!ss!.!cc!
)

endlocal