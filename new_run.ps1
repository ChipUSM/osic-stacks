param(
    [switch] $remote = $false, 
    [switch] $interactive = $false,
    [switch] $silent = $false,
    [switch] $clean = $false
)

$global:STACK_OPTIONS = [ordered]@{
    1 = 'analog-xk'
    2 = 'analog-xm'
    3 = 'analog-heavy'
    4 = 'digital-ator'
    5 = 'digital-icarus'
    6 = 'digital-heavy'
    7 = 'heavy'
    8 = "chipathon-tools"
}

$global:SELECTED_STACK='chipathon-tools'
$global:CONTAINER_NAME=$global:SELECTED_STACK
$global:EXECMODE='desktop'
$global:PDK="gf180mcuC"
$global:DIRECTORY=Get-Location | Foreach-Object { $_.Path }

$global:PARAMS = ""

New-Alias Call Invoke-Expression

function validate-environment() {
    Write-Host "Checking requirements and WSL updates" -ForegroundColor DarkGray
    
    Write-Host ""
    wsl --install Ubuntu --no-launch
    wsl --update
    Write-Host ""
}

function select-stack() {
    Write-Host "Please select an stack index:"

    $STACK_OPTIONS.GetEnumerator() | ForEach-Object {
        Write-Host "[$($_.Key)] - $($_.Value)" -ForegroundColor Cyan
    }

    $response = Read-Host -Prompt "Container stack to initialize [1-$($STACK_OPTIONS.Count)]"
    if ($response) {
        $global:SELECTED_STACK = $STACK_OPTIONS[$response-1]
    }

    $response = Read-Host -Prompt "Container instance name [default=$global:CONTAINER_NAME]"
    if ($response) {
        $global:CONTAINER_NAME = $response
    }
}

function select-execmode() {
    Write-Host "Please select an execution mode index"
    Write-Host '[1] - desktop' -ForegroundColor Cyan
    Write-Host '[2] - web' -ForegroundColor Cyan
    $response = Read-Host "Execution mode [1-2] [default=$global:EXECMODE]"

    if ($response -eq '1') {
        $global:EXECMODE = 'desktop'
    } elseif ($response -eq '2') {
        $global:EXECMODE = 'web'
    } else {
        Write-Host "Using default mode ($global:EXECMODE)"
    }
}

function bind-to-directory() {
    $response = Read-Host "Do you want to bind the container home directory into a windows directory? [N/y]"

    if ($response -eq 'y') {
        $global:DIRECTORY = Read-Host "Write the windows directory destination relative to WSL, for example `"/mnt/c/Users/Username/Desktop/ExampleFolder`"`n"
    }
}

function set-aditional-parameters() {
    $response = Read-Host -Prompt "Do you want to set additional arguments for the container instantiation? [N/y]"

    if ($response -eq 'y') {
        $response = Read-Host -Prompt "Write the additional arguments, for example -v <wsl_path>:<container_path>."
        $global:PARAMS += " $response"
    }
}

function force-pull() {
    $response = Read-Host -Prompt "Do you want to pull latest image? [N/y] [default=N]"

    if ($response -eq 'y') {
        $global:PARAMS += " --pull-always"
    }
}

function select-pdk() {
    Write-Host "Please select a pdk"
    Write-Host '[1] - gf180mcuC' -ForegroundColor Cyan
    Write-Host '[2] - sky130A' -ForegroundColor Cyan
    $response = Read-Host "Execution mode [1-2] [default=$global:PDK]"

    if ($response -eq '1') {
        $global:PDK = 'gf180mcuC'
    } elseif ($response -eq '2') {
        $global:PDK = 'sky130A'
    } else {
        Write-Host "Using default pdk ($global:PDK)"
    }
}

function attach-shell () {
    Call "docker exec -it $global:CONTAINER_NAME bash"
}

function run-docker-wsl() {
    # if($remote) {
    #     #$image = "--pull always git.1159.cl/mario1159/$SELECTED_STACK-$EXECMODE"
    #     $image = "git.1159.cl/mario1159/$SELECTED_STACK-$EXECMODE"
    # } else {
    #     $image = "$SELECTED_STACK-$EXECMODE"
    # }
    $image = "git.1159.cl/mario1159/$SELECTED_STACK-$EXECMODE"

    $global:PARAMS += " -d"
    $global:PARAMS += " --name $global:CONTAINER_NAME"
    $global:PARAMS += " -v /tmp/.X11-unix:/tmp/.X11-unix"
    $global:PARAMS += " -v /mnt/wslg:/mnt/wsl"

    $global:PARAMS += " -e WAYLAND_DISPLAY=`$WAYLAND_DISPLAY"
    $global:PARAMS += " -e DISPLAY=`$DISPLAY"
    $global:PARAMS += " -e XDG_RUNTIME_DIR=/mnt/wslg"
    $global:PARAMS += " -v /mnt/${global:DIRECTORY}:/home/designer/shared "

    #wsl -d Ubuntu bash -ic "docker run ${PARAMS} ${image}"
    echo "docker run ${PARAMS} ${image}"

    if ($?) {
        Write-Host "Container created successfully!" -ForegroundColor Green
        Write-Host "Enter the container with `"docker exec -it $global:CONTAINER_NAME bash`"" -ForegroundColor DarkGray

        attach-shell
    } else {
        Write-Host "Container creation failed, see logs above" -ForegroundColor Red
    }
}

function run-docker-win() {
    $image = "git.1159.cl/mario1159/$SELECTED_STACK-$EXECMODE"

    if ($clean) {    
        $global:PARAMS += "-it --rm"
        $global:COMMAND = "bash"
    } else {
        $global:PARAMS += "-d"
        $global:COMMAND = ""
    }
    $global:PARAMS += " --name $global:CONTAINER_NAME"
    $global:PARAMS += " --security-opt seccomp=unconfined"

    # $global:PARAMS += " -p '8888:8888'"

    $global:PARAMS += " -v '\\wsl.localhost\Ubuntu\mnt\wslg:/tmp'"
    $global:PARAMS += " -v ${global:DIRECTORY}:/home/designer/shared"
    #$global:PARAMS += " -v '\\wsl.localhost\Ubuntu\mnt\wslg\runtime-dir'%XDG_RUNTIME_DIR%"

    #$global:PARAMS += " -e WAYLAND_DISPLAY=`$WAYLAND_DISPLAY"
    $global:PARAMS += " -e PDK=$global:PDK"
    $global:PARAMS += " -e DISPLAY=:0"
    # $global:PARAMS += " -e XDG_RUNTIME_DIR=/mnt/wslg"
    # SET PARAMS=%PARAMS% -e DISPLAY=%DISPLAY%
    # SET PARAMS=%PARAMS% -e WAYLAND_DISPLAY=%WAYLAND_DISPLAY%
    # SET PARAMS=%PARAMS% -e XDG_RUNTIME_DIR=%XDG_RUNTIME_DIR%

    
    Call "docker run ${PARAMS} ${image} $global:COMMAND"

    if ($?) {
        Write-Host "Container created successfully!" -ForegroundColor Green
        Write-Host "Enter the container with `"docker exec -it $global:CONTAINER_NAME bash`"" -ForegroundColor DarkGray

        attach-shell
    } else {
        Write-Host "Container creation failed, see logs above" -ForegroundColor Red
    }
}

function run(){
    if ($silent) {
        Remove-Alias Call
        New-Alias Call Write-Host
    }

    Write-Host "OSIC-Stacks Container Creation" -ForegroundColor Green

    validate-environment

    if ($interactive) {
        select-stack
        select-execmode
        bind-to-directory
        set-aditional-parameters
        force-pull
    }

    run-docker-win
}

run