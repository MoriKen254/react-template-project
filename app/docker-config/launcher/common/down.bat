@echo off
@rem
@rem down.bat
@rem Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
@rem

setlocal enabledelayedexpansion

set APP_NAME=react_template

rem 時間計測フラグと--no-cacheフラグを初期化
set measure_time=0
set no_cache=

cd ../../../
set /p APP_VERSION=<./src/.app-version
set /p NODE_VERSION=<./src/.node-version

echo ◆◆◆◆◆ イメージをビルドします。 ◆◆◆◆◆
echo - タグ: %APP_VERSION%
echo - Node.jsバージョン: %NODE_VERSION%

docker compose -f docker-compose-%STAGE%.yaml down --remove-orphans

cd docker-config/launcher/prep

endlocal