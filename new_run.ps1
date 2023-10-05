param(
    [switch] $remote = $false, 
    [switch] $interactive = $false
)

$global:STACK_OPTIONS = [ordered]@{}

$global:SELECTED_STACK='chipathon-tools'
$global:CONTAINER_NAME='chipathon-tools'
$global:EXECMODE='desktop'
$global:DIRECTORY=Get-Location | Foreach-Object { $_.Path }

$global:PARAMS = ""

function validate-environment() {
    Write-Host "Checking requirements and WSL updates" -ForegroundColor DarkGrayWrite-Host ""

    Write-Host ""
    wsl --install Ubuntu --no-launch
    wsl --update
    Write-Host ""
}

function select-image() {
    Write-Host "Please select an image index:"

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

    $STACK_OPTIONS.GetEnumerator() | ForEach-Object {
        Write-Host "[$($_.Key)] - $($_.Value)" -ForegroundColor Cyan
    }

    $response = Read-Host -Prompt "Container image to initialize [1-$($STACK_OPTIONS.Count)]"
    $global:SELECTED_STACK = $STACK_OPTIONS[$response-1]

    $global:CONTAINER_NAME = Read-Host -Prompt "Container instance name [default=$global:SELECTED_STACK]"
    if (!$global:CONTAINER_NAME) {
        $global:CONTAINER_NAME = $global:SELECTED_STACK 
    }
}


function select-execmode() {
    $global:EXECMODE = $null
    while(!$global:EXECMODE) {
        Write-Host "Please select an execution mode index"
        Write-Host '[1] - desktop' -ForegroundColor Cyan
        Write-Host '[2] - web' -ForegroundColor Cyan
        $response = Read-Host "Execution mode [1-2]"
        if ($response -eq '1') {
            $global:EXECMODE = 'desktop'
        } elseif ($response -eq '2') {
            $global:EXECMODE = 'web'
        } else {
            Write-Host "Unexpected respose, please try again" -ForegroundColor Red
        }
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

function run-docker() {
    if($remote) {
        $image = "--pull always git.1159.cl/mario1159/$SELECTED_STACK-$EXECMODE"
    } else {
        $image = "$SELECTED_STACK-$EXECMODE"
    }

    $global:PARAMS += " -d"
    $global:PARAMS += " --name $global:CONTAINER_NAME"
    $global:PARAMS += " -v /tmp/.X11-unix:/tmp/.X11-unix"
    $global:PARAMS += " -v /mnt/wslg:/mnt/wsl"
    $global:PARAMS += " -e WAYLAND_DISPLAY=`$WAYLAND_DISPLAY"
    $global:PARAMS += " -e DISPLAY=`$DISPLAY"
    $global:PARAMS += " -e XDG_RUNTIME_DIR=/mnt/wslg"
    $global:PARAMS += "-v ${global:DIRECTORY}:/home/designer/shared "

    wsl -d Ubuntu bash -ic "docker run ${PARAMS} ${image}"
    #wsl -d Ubuntu bash -ic docker run -d --name chipathon-tools -v /tmp/.X11-unix:/tmp/.X11-unix -v /mnt/wslg:/mnt/wsl -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY -e DISPLAY=$DISPLAY -e XDG_RUNTIME_DIR=/mnt/wslg  chipathon-tools-desktop

    if ($?) {
        Write-Host "Container created successfully!" -ForegroundColor Green
        Write-Host "Enter the container with `"docker exec -it $global:CONTAINER_NAME bash`"" -ForegroundColor DarkGray
    } else {
        Write-Host "Container creation failed, see logs above" -ForegroundColor Red
    }
}

function run(){
    Write-Host "OSIC-Stacks Container Creation" -ForegroundColor Green

    # validate-environment

    if 
    ($interactive) {
        select-image
        select-execmod
        bind-to-directory
        set-aditional-parameters
    }

    run-docker
}

run