param([switch] $remote = $false)

Write-Host "OSIC-Stacks Container Creation" -ForegroundColor Green
Write-Host "Checking requirements and WSL updates" -ForegroundColor DarkGray

Write-Host ""
wsl --install Ubuntu --no-launch
wsl --update
Write-Host ""

Write-Host "Please select an image index:"

$stacks_options = @(
    'analog-xk'
    'analog-xm'
    'analog-heavy'
    'digital-ator'
    'digital-icarus'
    'digital-heavy'
    'heavy'
)

for($i = 0; $i -lt $stacks_options.Length; $i++) {
    $stack_option = $stacks_options[$i]
    Write-Host "[$($i+1)] - $stack_option" -ForegroundColor Cyan
}

$stack_index = Read-Host -Prompt "Container image to initialize [1-$($stacks_options.Length)]"
$selected_stack = $stacks_options[$stack_index-1]
$container_name = Read-Host -Prompt "Container instance name [default=$selected_stack]"
if (!$container_name) { $container_name = $selected_stack }

$execmode = ''
while(!$execmode) {
    Write-Host "Please select an execution mode index"
    Write-Host '[1] - desktop' -ForegroundColor Cyan
    Write-Host '[2] - web' -ForegroundColor Cyan
    $response = Read-Host "Execution mode [1-2]"
    if ($response -eq '1') {
        $execmode = 'desktop'
    } elseif ($response -eq '2') {
        $execmode = 'web'
    } else {
        Write-Host "Unexpected respose, please try again" -ForegroundColor Red
    }
}

$additional_options = ''
if($remote) {
    $image = "git.1159.cl/mario1159/$selected_stack-$execmode"
    $additional_options = '--pull always ' 
} else {
    $image = "$selected_stack-$execmode"
}

$response = Read-Host "Do you want to bind the container home directory into a windows directory? [N/y]"

if ($response -eq 'y') {
    $directory = Read-Host "Write the windows directory destination relative to WSL, for example `"/mnt/c/Users/Username/Desktop/ExampleFolder`"`n"
    $additionaloptions = -join($additionaloptions, "-v ${directory}:/home/designer/shared ")
}

$response = Read-Host -Prompt "Do you want to set additional arguments for the container instantiation? [N/y]"

if ($response -eq 'y') {
    $response = Read-Host -Prompt "Write the additional arguments, for example -v <wsl_path>:<container_path>."
    $additionaloptions = -join($additionaloptions, $response)
}

Write-Host ""

$dockercommand = ("docker run -d " +
    "--name $container_name " +
    "-v /tmp/.X11-unix:/tmp/.X11-unix " +
    "-v /mnt/wslg:/mnt/wsl " +
    "-e WAYLAND_DISPLAY=`$WAYLAND_DISPLAY " +
    "-e DISPLAY=`$DISPLAY " +
    "-e XDG_RUNTIME_DIR=/mnt/wslg " +
    "$additional_options "+
    $image)

wsl -d Ubuntu bash -ic $dockercommand

if ($?) {
    Write-Host "Container created successfully!" -ForegroundColor Green
    Write-Host "Enter the container with `"docker exec -it $containername bash`"" -ForegroundColor DarkGray
} else {
    Write-Host "Container creation failed, see logs above" -ForegroundColor Red
}