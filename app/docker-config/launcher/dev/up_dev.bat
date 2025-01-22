@echo off
@rem
@rem up_dev.bat
@rem Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
@rem

setlocal enabledelayedexpansion

set STAGE=dev

cd ../common
up.bat %*

endlocal