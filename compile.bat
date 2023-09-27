@echo off
setlocal

@REM SET BASE_IMG=git.1159.cl/mario1159/analog-xk-web:latest
SET BASE_IMG=git.1159.cl/mario1159/analog-xk-desktop:latest
SET RESULT_IMAGE=akilesalreadytaken/analog-tools:latest

SET CALL=call
:parse
    IF /I ""%1""==""""       GOTO run
    IF /I ""%1""==""--help"" GOTO documentation
    IF /I ""%1""==""-h""     GOTO documentation
    IF /I ""%1""==""--dry""  ( SET "CALL=echo" )
    IF /I ""%1""==""-s""     ( SET "CALL=echo" )
    IF /I ""%1""==""--path"" ( SET "DESIGNS=%~2" && SHIFT )
    IF /I ""%1""==""-p""     ( SET "DESIGNS=%~2" && SHIFT )
    SHIFT
    GOTO parse


:documentation
    echo Usage: run.bat %~nx0 [-h^|--help] [-s^|--dry-run]
    GOTO end


:run
    %CALL% docker build --build-arg BASE_IMG=%BASE_IMG% -t %RESULT_IMAGE% -f stacks/analog-tools/Dockerfile stacks/analog-tools/
    GOTO end

:end
    endlocal


:normalizepath
    SET DESIGNS=%~f1
    EXIT /B


:: Get DISPLAY from WSL
::wsl --exec bash --norc -c 'echo $DISPLAY'

:: Get current path of batsh script
::SET BATCH_PATH=%~dpnx0
