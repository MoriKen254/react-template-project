@echo off
@rem
@rem restart_prep.bat
@rem Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
@rem

setlocal enabledelayedexpansion

set STAGE=prep

cd ../common
restart.bat %*

endlocal