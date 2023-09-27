@echo off
setlocal

SET IMAGE=akilesalreadytaken/analog-xk:latest
SET IMAGE=akilesalreadytaken/analog-tools:latest
::SET IMAGE=git.1159.cl/mario1159/analog-xk-web:latest

SET CALL=call
:parse
    IF /I ""%~1""==""""       GOTO run
    IF /I ""%~1""==""--help"" GOTO documentation
    IF /I ""%~1""==""-h""     GOTO documentation
    IF /I ""%~1""==""--dry""  ( SET "CALL=echo" )
    IF /I ""%~1""==""-s""     ( SET "CALL=echo" )
    IF /I ""%~1""==""-v""     ( SET "ENABLE_VNC=" )
    IF /I ""%~1""==""--vnc""  ( SET "ENABLE_VNC=" )
    IF /I ""%~1""==""--path"" ( SET "DESIGNS=%~2" && SHIFT )
    IF /I ""%~1""==""-p""     ( SET "DESIGNS=%~2" && SHIFT )
    IF /I ""%~1""==""-k""     ( SET "PDK=%~2" && SHIFT )
    IF /I ""%~1""==""--pdk""  ( SET "PDK=%~2" && SHIFT )
    SHIFT
    GOTO parse


:documentation
    echo Usage: run.bat %~nx0 [ OPTIONS ]
    echo.
    echo   -h --help            Show usage information
    echo   -s --dry             See the commands to be executed
    echo   -p --path PATH       Link to a directory
    echo   -v --vnc             Enable the vnc in port "https:\\localhost:8444"
    echo                        If vnc is not working, execute:
    echo                           ^$ xfce4-session --display=:1 ^&
    echo   -k --pdk PDK         Set the PDK to be used: gf180mcuC ^| sky130A
    echo                        By default: gf180mcuC
    GOTO end


:run
    :: Set fixed parameters
    :::::::::::::::::::::::::::
    IF NOT DEFINED DESIGNS         SET DESIGNS=%CD%
    CALL :NORMALIZEPATH %DESIGNS%

    IF NOT DEFINED PDK             SET PDK=gf180mcuC

    IF NOT DEFINED DOCKER_USER     SET DOCKER_USER=git.1159.cl/mario1159
    IF NOT DEFINED DOCKER_IMAGE    SET DOCKER_IMAGE=analog-xk
    IF NOT DEFINED DOCKER_TAG      SET DOCKER_TAG=latest

    IF NOT DEFINED CONTAINER_USER  SET CONTAINER_USER=1000
    IF NOT DEFINED CONTAINER_GROUP SET CONTAINER_GROUP=1000

    IF NOT DEFINED CONTAINER_NAME  SET CONTAINER_NAME=analog-tools

    IF NOT DEFINED JUPYTER_PORT    SET JUPYTER_PORT=8888
    IF NOT DEFINED VNC_PORT        SET VNC_PORT=8444

    :: Get parameters from wsl
    ::::::::::::::::::::::::::
    SET WSL_GET_PARAMETER=wsl --exec bash --norc -c "echo $DISPLAY"
    @REM SET WSL_GET_PARAMETER=wsl -d docker-desktop --exec ash -c "echo $DISPLAY"
    FOR /F "USEBACKQ" %%i IN (`%WSL_GET_PARAMETER%`) DO ( SET "DISPLAY=%%i" )

    SET WSL_GET_PARAMETER=wsl --exec bash --norc -c "echo $WAYLAND_DISPLAY"
    @REM SET WSL_GET_PARAMETER=wsl -d docker-desktop --exec ash -c "echo $WAYLAND_DISPLAY"
    FOR /F "USEBACKQ" %%i IN (`%WSL_GET_PARAMETER%`) DO ( SET "WAYLAND_DISPLAY=%%i" )

    SET WSL_GET_PARAMETER=wsl --exec bash --norc -c "echo $XDG_RUNTIME_DIR"
    @REM SET WSL_GET_PARAMETER=wsl -d docker-desktop --exec ash -c "echo $XDG_RUNTIME_DIR"
    FOR /F "USEBACKQ" %%i IN (`%WSL_GET_PARAMETER%`) DO ( SET "XDG_RUNTIME_DIR=%%i" )

    :: Validate parameters
    ::::::::::::::::::::::
    IF %CONTAINER_USER% NEQ 0 IF %CONTAINER_USER% LSS 1000 (
        echo WARNING: Selected User ID %CONTAINER_USER% is below 1000. This ID might interfere with User-IDs inside the container and cause undefined behaviour!
    )
    IF %CONTAINER_GROUP% NEQ 0 IF %CONTAINER_GROUP% LSS 1000 (
        echo WARNING: Selected Group ID %CONTAINER_GROUP% is below 1000. This ID might interfere with Group-IDs inside the container and cause undefined behaviour!
    )

    :: Attach to existing container
    :::::::::::::::::::::::::::::::
    docker container inspect %CONTAINER_NAME% 2>&1 | find "Status" | find /i "running"
    IF NOT ERRORLEVEL 1 (
        ECHO Container %CONTAINER_NAME% is running!
        ECHO   Stop with "docker stop %CONTAINER_NAME%"
        ECHO   Remove with "docker rm %CONTAINER_NAME%" if required.
        GOTO attach_shell
    )
    docker container inspect %CONTAINER_NAME% 2>&1 | find "Status" | find /i "exited"
    IF NOT ERRORLEVEL 1 (
        ECHO Container %CONTAINER_NAME% exists. 
        ECHO   Restart with "docker start %CONTAINER_NAME%"
        ECHO   Or remove with "docker rm %CONTAINER_NAME%" if required.
        GOTO restart_shell
    )

    :: Set environment, variables and run the container
    :::::::::::::::::::::::::::::::::::::::::::::::::::
    echo Check requirements
    %CALL% wsl --install Ubuntu --no-launch
    %CALL% wsl --update

    echo Container does not exist, creating %CONTAINER_NAME% ...

    SET PARAMS=-d
    SET PARAMS=%PARAMS% --name %CONTAINER_NAME%
    ::SET PARAMS=%PARAMS% --user %CONTAINER_USER%:%CONTAINER_GROUP%
    SET PARAMS=%PARAMS% --security-opt seccomp=unconfined

    SET PARAMS=%PARAMS% -p %JUPYTER_PORT%:8888
    SET PARAMS=%PARAMS% -p %VNC_PORT%:8444

    SET PARAMS=%PARAMS% -v "%DESIGNS%":/home/designer/shared
    SET PARAMS=%PARAMS% -v "\\wsl.localhost\Ubuntu\mnt\wslg":/tmp
    SET PARAMS=%PARAMS% -v "\\wsl.localhost\Ubuntu\mnt\wslg\runtime-dir":%XDG_RUNTIME_DIR%
    @REM SET PARAMS=%PARAMS% -v "\\wsl.localhost\docker-desktop\mnt\host\wslg":/tmp
    @REM SET PARAMS=%PARAMS% -v "\\wsl.localhost\docker-desktop\mnt\host\wslg\runtime-dir":%XDG_RUNTIME_DIR%
    
    SET PARAMS=%PARAMS% -e PDK=%PDK%
    SET PARAMS=%PARAMS% -e DISPLAY=%DISPLAY%
    SET PARAMS=%PARAMS% -e WAYLAND_DISPLAY=%WAYLAND_DISPLAY%
    SET PARAMS=%PARAMS% -e XDG_RUNTIME_DIR=%XDG_RUNTIME_DIR%
    @REM IF NOT DEFINED ENABLE_VNC (
    @REM ) ELSE (
    @REM )

    IF NOT DEFINED IMAGE (
        SET IMAGE=%DOCKER_USER%/%DOCKER_IMAGE%
        IF DEFINED DOCKER_TAG  SET IMAGE=%IMAGE%:%DOCKER_TAG%
    )

    @REM SET COMMAND=jupyter-lab --no-browser
    @REM SET COMMAND=sleep infinity

    %CALL% docker run %PARAMS% %IMAGE% %COMMAND%

    GOTO attach_shell


:attach_shell
    %CALL% docker exec -it %CONTAINER_NAME% bash
    GOTO end


:restart_shell
    %CALL% docker start %CONTAINER_NAME%
    GOTO attach_shell


:end
    endlocal
    EXIT


:normalizepath
    SET DESIGNS=%~f1
    EXIT /B


:: Get DISPLAY from WSL
::wsl --exec bash --norc -c 'echo $DISPLAY'

:: Get current path of batsh script
::SET BATCH_PATH=%~dpnx0
