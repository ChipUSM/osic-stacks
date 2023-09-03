# OSIC Stacks
 Open source Integrated Circuits Docker Stacks

## Stacks

- analog-xk: Analog workflow using XScheme & KLayout
- analog-xm: Analog workflow using XScheme & Magic
- digital-ator: Digital workflow using Verilator & Yosys
- digital-icarus: Digital workflow using Icarus & Yosys
- heavy: Workflow with all the previous tools 

## Usage

There are scripts provided for running the containers for each OS, this is because containers require binding the display enviroment variables to enable graphic output.

### Windows

This script will run the container inside wsl and bind the enviroments variables for [wslg](https://github.com/microsoft/wslg/blob/main/samples/container/Containers.md).

```powershell -executionpolicy bypass -file .\scripts\wsl_start.ps1```

### Linux

TODO:

## Build

A singular stack image can be builded using docker in the following way.
> Note: Each stack image requires their correspondent base image installed.

```docker build -t <tag> -f <arch/jammy>.Dockerfile <path>```

For building all stacks, build the project with docker compose.

```docker compose build```

## Custom Images