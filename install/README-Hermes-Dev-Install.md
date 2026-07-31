# README-Hermes-Dev-Install.md

This document describes the purpose and behaviour of the script `hermes-dev-install.sh`.  
The script is executed inside a Proxmox LXC container and is responsible for installing and updating all components required for Hermes Dev.

The script supports two modes:

1. Initial installation  
2. Update mode when Hermes Dev is already installed

The mode is determined by the presence of the configuration file:
- /etc/hermes-dev/install.conf


If the file does not exist, the script performs a full installation.  
If the file exists, the script performs an update.

---

## Installation Mode

During a fresh installation, the script performs the following actions:

1. Updates and upgrades system packages.
2. Installs required dependencies including:
   - curl  
   - git  
   - python3  
   - python3-pip  
   - python3-venv  
   - build-essential  
3. Detects the system architecture.
4. Downloads and installs the correct Herdr binary for the architecture.
5. Installs Ollama and pulls the default model.
6. Installs Hermes CLI using pip.
7. Installs Hermes Gateway if gateway support is enabled.
8. Clones and installs Hermes Agents if an agent repository URL is provided.
9. Creates the configuration file at `/etc/hermes-dev/install.conf`.
10. Creates `/usr/bin/update` so the container can update itself.

After installation completes, Hermes Dev is fully set up inside the container.

---

## Update Mode

When the configuration file exists, the script enters update mode.  
In update mode, the script performs the following actions:

1. Loads the existing configuration.
2. Updates system packages.
3. Downloads the latest Herdr binary.
4. Updates Hermes CLI and Hermes Gateway.
5. Updates Hermes Agents by pulling the latest changes from the agent repository.
6. Updates Ollama and the configured model.
7. Increments the update version number.
8. Writes the updated configuration back to disk.

Update mode is safe to run multiple times and ensures all components remain current.

---

## Components Installed by the Script

### Herdr  
Herdr is installed as a standalone binary.  
The script selects the correct binary based on system architecture and places it in `/usr/local/bin`.

### Python Environment  
Python3, pip, and venv are installed to support Hermes CLI, Hermes Gateway, and any Python-based agent functionality.

### Hermes CLI  
The Hermes command-line interface is installed using pip.  
This provides the main user-facing tools for interacting with Hermes Dev.

### Hermes Gateway (optional)  
If gateway support is enabled, the script installs and starts the Hermes Gateway service.  
The gateway can be updated automatically during update mode.

### Hermes Agents (optional)  
If an agent repository URL is provided, the script clones the repository into `/opt/hermes-agents` and registers the agents with Hermes.  
During updates, the script pulls the latest changes from the repository.

### Ollama  
Ollama is installed to provide model execution support.  
The script pulls the default model and updates both the engine and model during update mode.

---

## Configuration File

The installer maintains the file:
- /etc/hermes-dev/install.conf


This file stores:
- Architecture  
- Model name  
- Install date  
- Install version  
- Update version  
- Gateway enabled flag  
- Agent repository URL  
- GPU pass-through flag  

This information is used to preserve settings and determine update behaviour.

---

## Update Entry Point

The installer creates the script:
- /usr/bin/update


This script retrieves the latest host-side entry script from the ProxmoxVED repository and executes its update logic.  
This allows updates to be performed entirely from inside the container.

---

## Summary

`hermes-dev-install.sh` is responsible for:

- Installing Hermes Dev and all required components  
- Setting up Herdr  
- Preparing Python support for Hermes CLI and Gateway  
- Installing Ollama and the default model  
- Enabling optional Gateway and Agent support  
- Creating persistent configuration  
- Providing unified update functionality  

This script is designed to be extended as Hermes Dev evolves and can serve as a template for additional applications.
