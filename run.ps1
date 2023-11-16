param(
    [switch] $pull = $false, 
    [switch] $interactive = $false,
    [switch] $silent = $false,
    [switch] $attach = $false,
    [switch] $download = $false
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
$global:PDK="gf180mcuD"
$global:DIRECTORY=Get-Location | Foreach-Object { $_.Path }
$global:WSL_DISTRO="NO DISTRO"

$global:PARAMS = ""

New-Alias Call Invoke-Expression

function debug($fname, $message) {
    Write-Host "[$fname] $message" -ForegroundColor Green
}

function get-ubuntu-distro() {
    # Identify if distro has (Predeterminado) or something like that
    Invoke-Expression "wsl --list" | ForEach-Object {
        if ($_ -match '\)' ) {
            $global:WSL_DISTRO=$_.split('(')[0].replace(" ","")
        }
    }

    debug "get-ubuntu-distro" "Linux distribution: $global:WSL_DISTRO"
}

function validate-environment() {
    Write-Host "Checking requirements and WSL updates" -ForegroundColor DarkGray
    
    Write-Host ""
    Call "wsl --install Ubuntu --no-launch"
    Call "wsl --update"
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
        $global:DIRECTORY = Read-Host "Write the windows directory destination , for example `"C:\Users\Username\Desktop\ExampleFolder`"`n"
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
        $global:PARAMS += " --pull always"
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

function path-conversion() {
    $directory, $other = $args
    $drive, $path = $directory.split(":")

    echo "/mnt/$($drive.tolower())$($path.replace("\","/"))"
}

function get-value-from-wsl() {
    $variable, $other = $args

    $cmd = "wsl bash -c `'echo `$$variable`'"

    # Simple replacement
    #$cmd = "wsl -d $global:WSL_DISTRO bash -c `'echo `$$variable`'"
    #$cmd = "wsl -d `'$global:WSL_DISTRO`' bash -c `'echo `$$variable`'"

    # Using parenthesis
    #$cmd = "wsl -d $($global:WSL_DISTRO) bash -c `'echo `$$variable`'"
    #$cmd = "wsl -d `'$($global:WSL_DISTRO)`' bash -c `'echo `$$variable`'"
    #$cmd = "wsl -d `"$($global:WSL_DISTRO)`" bash -c `'echo `$$variable`'"

    # Using curly braces
    #$cmd = "wsl -d ${global:WSL_DISTRO} bash -c `'echo `$$variable`'"
    #$cmd = "wsl -d '${global:WSL_DISTRO}' bash -c `'echo `$$variable`'"

    # Using here strings (Never worked)
    # @"
    # "wsl -d $global:WSL_DISTRO bash -c `'echo `$$variable`'"
    # "@

    debug "get-value-from-wsl" "Command: $cmd"

    $response = Invoke-Expression "$cmd"
    debug "get-value-from-wsl" "Response: $response"
    return $response
}

function set-common-parameters () {
    $global:IMAGE = "git.1159.cl/mario1159/$SELECTED_STACK-$EXECMODE"

    if ($attach) {
        $global:PARAMS += " -it --rm"
        $global:COMMAND = "bash"
    } else {
        $global:PARAMS += " -d"
        $global:COMMAND = ""
    }

    if ($pull) {
        $global:PARAMS += " --pull always"
    }

    $global:PARAMS += " --name $global:CONTAINER_NAME"
    $global:PARAMS += " --security-opt seccomp=unconfined"

    # $global:PARAMS += " -p '8888:8888'"
    # $global:PARAMS += " -p '8082:8082'"

    $global:PARAMS += " -e PDK=$global:PDK"

    $global:PARAMS += " -e DISPLAY=$(get-value-from-wsl "DISPLAY")"
    $global:PARAMS += " -e WAYLAND_DISPLAY=$(get-value-from-wsl "WAYLAND_DISPLAY")"
    $global:PARAMS += " -e XDG_RUNTIME_DIR=$(get-value-from-wsl "XDG_RUNTIME_DIR")"
}

function run-docker-wsl() {
    $global:DIRECTORY = path-conversion $global:DIRECTORY

    $global:PARAMS += " -v /tmp/.X11-unix:/tmp/.X11-unix"
    $global:PARAMS += " -v /mnt/wslg:/mnt/wsl"
    $global:PARAMS += " -v ${global:DIRECTORY}:/home/designer/shared "

    #Call "wsl -d $global:WSL_DISTRO bash --noprofile --norc -ic `"docker run $global:PARAMS $global:IMAGE $global:COMMAND`""
    Call "wsl bash --noprofile --norc -ic `"docker run $global:PARAMS $global:IMAGE $global:COMMAND`""

    if ($?) {
        Write-Host "Container created successfully!" -ForegroundColor Green
        Write-Host "Enter the container with `"docker exec -it $global:CONTAINER_NAME bash`"" -ForegroundColor DarkGray

        attach-shell
    } else {
        Write-Host "Container creation failed, see logs above" -ForegroundColor Red
    }
}

function run-docker-win() {
    $global:PARAMS += " -v '\\wsl.localhost\$global:WSL_DISTRO\mnt\wslg:/tmp'"
    $global:PARAMS += " -v ${global:DIRECTORY}:/home/designer/shared"
    #$global:PARAMS += " -v '\\wsl.localhost\$global:WSL_DISTRO\mnt\wslg\runtime-dir'%XDG_RUNTIME_DIR%"

    Call "docker run $global:PARAMS $global:IMAGE $global:COMMAND"

    if ($?) {
        Write-Host "Container created successfully!" -ForegroundColor Green
        Write-Host "Enter the container with `"docker exec -it $global:CONTAINER_NAME bash`"" -ForegroundColor DarkGray

        attach-shell
    } else {
        Write-Host "Container creation failed, see logs above" -ForegroundColor Red
    }
}

function download-run-bat () {
    if (!$download) { return }

    try {
        $response = Call "Invoke-WebRequest -URI https://git.1159.cl/Mario1159/osic-stacks/raw/branch/main/run.ps1 -OutFile run.ps1"
    } catch {
        $StatusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Error downloading file :( ($($StatusCode))" -ForegroundColor Red
        return
    }

    Write-Host "run.bat updated successfully" -ForegroundColor Green
}

function run(){
    if ($silent) {
        Write-Host "[Silent Mode]" -ForegroundColor Yellow
        Remove-Alias Call
        New-Alias Call Write-Host
    }

    Write-Host "OSIC-Stacks Container Creation" -ForegroundColor Green

    download-run-bat
    validate-environment
    get-ubuntu-distro

    if ($interactive) {
        select-stack
        select-execmode
        bind-to-directory
        set-aditional-parameters
        force-pull
    }

    set-common-parameters

    #run-docker-win
    run-docker-wsl
}

run
