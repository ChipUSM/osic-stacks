---
gitea: none
title: hello
include_toc: true
---
[![License: MIT](https://img.shields.io/badge/License-LGPL_v3-blue.svg)](https://opensource.org/license/mit/)


# OSIC Stacks
*Open Source Integrated Circuits Docker Stacks*

## Stacks

- **analog-xk**: Analog workflow using XScheme & KLayout
- **analog-xm**: Analog workflow using XScheme & Magic
- **digital-ator**: Digital workflow using Verilator & Yosys
- **digital-icarus**: Digital workflow using Icarus & Yosys
- **heavy**: Workflow with all the previous tools 

## Usage

Follow these 3 steps to get your container ready.

### 1. Starting a container with graphics output

Scripts are provided for creating the containers in both Windows and Linux.
These scripts automate the binding of graphics environment variables to the container in order to enable graphics inside the docker container.

#### Windows

Execute the next script in powershell.
```pwsh
& ([scriptblock]::Create((irm https://git.1159.cl/Mario1159/osic-stacks/raw/branch/main/scripts/wsl_start.ps1))) -remote
```
 This script will run the container inside wsl and bind the enviroments variables for [wslg](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md).

#### Linux
Execute the next script in your terminal. Make sure you have `curl` already installed.
```sh
curl https://git.1159.cl/Mario1159/osic-stacks/raw/branch/main/scripts/linux_start.sh -o linux_start.sh
```

### 2. Connecting to the container
After creating and starting the container, enter to it executing a shell with docker.
```sh
docker exec -it <container_name> bash
```

### 3. Configure Volare

List the available PDKs and choose one to install.

```sh
volare ls-remote --pdk <sky130/gf180mcu>
volare enable --pdk <sky130/gf180mcu> <version_id>
```

After you have set up the PDK, you can finally start developing your own designs!

## Build

A singular stack image can be builded using docker in the following way.
> Note: Each stack image requires their correspondent base image installed.

```sh
docker build -t <tag> -f <arch/jammy>.Dockerfile <path>
```

## Custom Images