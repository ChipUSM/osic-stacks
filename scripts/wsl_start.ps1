param([switch] $remote = $false)

$imagename = Read-Host -Prompt 'Container image to initialize'
$containername = Read-Host -Prompt 'Container instance name [default=$imagename]'
if (!$containername) { $containername = $imagename }

if($remote) {
    $image = "git.1159.cl/mario1159/$imagename"
} else {
    $image = $imagename
}

$command = ("docker run -d " +
    "--name $containername " +
    "-v /tmp/.X11-unix:/tmp/.X11-unix " +
    "-v /mnt/wslg:/mnt/wsl " +
    "-e WAYLAND_DISPLAY=`$WAYLAND_DISPLAY " +
    "-e DISPLAY=`$DISPLAY " +
    "-e XDG_RUNTIME_DIR=/mnt/wslg " +
    $image)

wsl bash -ic $command