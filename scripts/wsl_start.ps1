param([switch] $remote = $false)

Write-Host "OSIC-Stacks Container Creation" -ForegroundColor Green
Write-Host "Checking WSL updates" -ForegroundColor DarkGray

Write-Host ""
wsl --update
Write-Host ""

Write-Host "Please select an image index:"

$imageoptions = @(
    'analog-xk'
    'analog-xm'
    'digital-ator'
    'digital-icarus'
    'heavy'
)

for($i = 0; $i -lt $imageoptions.Length; $i++) {
    $imageoption = $imageoptions[$i]
    Write-Host "$i - $imageoption" -ForegroundColor Cyan
}

$imageindex = Read-Host -Prompt "Container image to initialize [0-$($imageoptions.Length)]"
$imagename = $imageoptions[$imageindex]
$containername = Read-Host -Prompt "Container instance name [default=$imagename]"
if (!$containername) { $containername = $imagename }

if($remote) {
    $image = "git.1159.cl/mario1159/$imagename"
} else {
    $image = $imagename
}

Write-Host ""

$dockercommand = ("docker run -d " +
    "--name $containername " +
    "-v /tmp/.X11-unix:/tmp/.X11-unix " +
    "-v /mnt/wslg:/mnt/wsl " +
    "-e WAYLAND_DISPLAY=`$WAYLAND_DISPLAY " +
    "-e DISPLAY=`$DISPLAY " +
    "-e XDG_RUNTIME_DIR=/mnt/wslg " +
    $image)

wsl -d Ubuntu bash -ic $dockercommand

if ($?) {
    Write-Host "Container created successfully!" -ForegroundColor Green
    Write-Host "Enter the container with `"docker exec -it $containername bash`"" -ForegroundColor DarkGray
} else {
    Write-Host "Container creation failed, see logs above" -ForegroundColor Red
}