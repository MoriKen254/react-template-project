@echo off
@rem
@rem up_prep.bat
@rem Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
@rem

setlocal enabledelayedexpansion

set STAGE=prep

cd ../common
up.bat %*

endlocal