
call ".\npm_install.bat"

:_minerstart
node send_universal.js --api tonapi --givers 5000 --bin amd
goto _minerstart

pause