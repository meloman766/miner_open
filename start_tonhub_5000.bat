
call ".\npm_install.bat"

:_minerstart
node send_universal.js --api tonhub --givers 5000
goto _minerstart

pause