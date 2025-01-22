@echo off
@rem
@rem exec.bat
@rem Copyright (C) 2024 MoriKen <masamorobo@gmail.com>
@rem

setlocal enabledelayedexpansion

set APP_NAME=react_template

docker exec -it %APP_NAME%_container_%STAGE% /bin/bash

endlocal