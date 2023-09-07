param([switch] $remote = $false)

Write-Host "OSIC-Stacks Container Creation" -ForegroundColor Green
Write-Host "Checking requirements and WSL updates" -ForegroundColor DarkGray

Write-Host ""
wsl --install Ubuntu --no-launch
wsl --update
Write-Host ""

Write-Host "Please select an image index:"

$imageoptions = @(
    'analog-xk'
    'analog-xm'
    'analog-heavy'
    'digital-ator'
    'digital-icarus'
    'digital-heavy'
    'heavy'
)

for($i = 0; $i -lt $imageoptions.Length; $i++) {
    $imageoption = $imageoptions[$i]
    Write-Host "$i - $imageoption" -ForegroundColor Cyan
}

$imageindex = Read-Host -Prompt "Container image to initialize [0-$($imageoptions.Length-1)]"
$imagename = $imageoptions[$imageindex]
$containername = Read-Host -Prompt "Container instance name [default=$imagename]"
if (!$containername) { $containername = $imagename }

if($remote) {
    $image = "git.1159.cl/mario1159/$imagename"
} else {
    $image = $imagename
}

$response = Read-Host "Do you want to bind the container home directory into a windows directory? [N/y]"

$additionaloptions = ''
if ($response -eq 'y') {
    $directory = Read-Host "Write the windows directory destination relative to WSL, for example `"/mnt/c/Users/Username/Desktop/ExampleFolder`"`n"
    mkdir -Force $directory | Out-Null
    $additionaloptions = "-v ${directory}:/home/designer"
}

$response = Read-Host -Prompt "Do you want to set additional arguments for the container instantiation? [N/y]"

if ($response -eq 'y') {
    $response = Read-Host -Prompt "Write the additional arguments, for example -v <wsl_path>:<container_path>."
    $additionaloptions = -join($additionaloptions, $response)
}

Write-Host ""

$dockercommand = ("docker run -d " +
    "--name $containername " +
    "-v /tmp/.X11-unix:/tmp/.X11-unix " +
    "-v /mnt/wslg:/mnt/wsl " +
    "-e WAYLAND_DISPLAY=`$WAYLAND_DISPLAY " +
    "-e DISPLAY=`$DISPLAY " +
    "-e XDG_RUNTIME_DIR=/mnt/wslg " +
    "$additionaloptions "+
    $image)

wsl -d Ubuntu bash -ic $dockercommand

if ($?) {
    Write-Host "Container created successfully!" -ForegroundColor Green
    Write-Host "Enter the container with `"docker exec -it $containername bash`"" -ForegroundColor DarkGray
} else {
    Write-Host "Container creation failed, see logs above" -ForegroundColor Red
}