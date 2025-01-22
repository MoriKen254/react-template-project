@echo off
@rem
@rem restart.bat
@rem Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
@rem

setlocal enabledelayedexpansion

set APP_NAME=react_template

rem 時間計測フラグと--no-cacheフラグを初期化
set measure_time=0
set no_cache=

rem 引数をチェック
:parse_args
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

cd ../../../
set /p APP_VERSION=<./src/.app-version
set /p NODE_VERSION=<./src/.node-version

echo ◆◆◆◆◆ イメージをビルドします。 ◆◆◆◆◆
echo - タグ: %APP_VERSION%
echo - Node.jsバージョン: %NODE_VERSION%

docker compose -f docker-compose-%STAGE%.yaml down --remove-orphans
docker compose -f docker-compose-%STAGE%.yaml up -d --remove-orphans

cd docker-config/launcher/prep

endlocal