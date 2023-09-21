---
gitea: none
title: hello
include_toc: true
---
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/license/mit/)


# OSIC Stacks
*Open Source Integrated Circuits Docker Stacks*

## Highlights

- Simple by design, intended for ease to use.
- IC design tools evolve quickly, a rolling release distribution allows you to have the latest version of your tool set.
- Docker images can be heavy, thus these images are distributed in stacks, choose the best fit for your task.
- Flexible, these containers doesn't restrict you to extend your development environment, feel free to install your own packages.

## Stacks

- **analog-xk**: Analog workflow using XSchem & KLayout
- **analog-xm**: Analog workflow using XSchem & Magic
- **analog-heavy**: Workflow with all the analog tools
- **digital-ator**: Digital workflow using Verilator & Yosys
- **digital-icarus**: Digital workflow using Icarus & Yosys
- **digital-heavy**: Workflow with all the digital tools
- **heavy**: Workflow with all the previous tools 

## Usage

Follow these 3 steps to get your container ready.

### 1. Starting a container with graphics output

Scripts are provided for creating the containers in both Windows and Linux.
These scripts automate the binding of graphics environment variables to the container in order to enable graphics inside the docker container.

#### Windows

Execute the next script in powershell.
```pwsh
& ([scriptblock]::Create((irm https://git.1159.cl/Mario1159/osic-stacks/raw/branch/main/run.ps1))) -remote
```
 This script will run the container inside wsl and bind the enviroments variables for [wslg](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md).

#### Linux
Execute the next script in your terminal replacing `<container_name>` and `<git.1159.cl/mario1159/image>`.
```sh
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name <container_name> <git.1159.cl/mario1159/image>
```

> For Wayland compositors make sure you have XWayland installed

#### macOS / OS X

Install `Xquartz` and run the linux previous command.

### 2. Connecting to the container

#### Desktop

After creating and starting the container, enter to it executing a shell with docker.
```sh
docker exec -it <container_name> bash
```

#### Web

Connect from the web to the VNC client at `localhost:8444`.

### 3. Configure Volare

List the available PDKs and choose one to install.

| PDK Technology | PDK Variant |
|----------------|-------------|
| sky130         | sky130A     |
|                | sky130B     |
| gf180mcu       | gf180mcuA   |
|                | gf180mcuB   |
|                | gf180mcuC   |

Replace `<pdk_variant>` and `<pdk_tech>` correspondingly by one of the PDKs listed above.
```sh
echo 'export PDK=<pdk_variant>' >> ~/.bashrc 
volare ls-remote --pdk <pdk_tech>
volare enable --pdk <pdk_tech> <version_id>
```

After you have set up the PDK, you can finally start developing your own designs!

## Installing additional packages

For the arch based images you can install packages from the official arch repository using `pacman`.

```pacman -S <package_name>```

or you can also install packages from the AUR using paru.

```paru <package_name>```

## Custom Images

For creating an image with your own pre-installed set of packages for your team you can create your own docker image extending the stacks, just as the stacks extend the base image. For reference check the stacks dockerfiles.

### Build

A singular stack image can be builded using docker in the following way from the repository root path.

```sh
docker build --no-cache -t osicstacks-base-<desktop/web> -f base/<desktop/web>.Dockerfile .
docker build --no-cache --build-arg BASE_IMG=osicstacks-base-<desktop/web> --target <stack>-<desktop/web> -t <tag> -f stacks/<stack>.Dockerfile .
```

### Local Run

Images can be tested and runned in the following way.

#### Windows
```pwsh
powershell.exe -ExecutionPolicy Bypass run.ps1
```

#### Linux
```sh
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name <container_name> <tag>
```
