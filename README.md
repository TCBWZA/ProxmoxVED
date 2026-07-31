# ProxmoxVED  
A collection of Proxmox LXC installation scripts following the Community‑Scripts layout and execution model.  
Each application is installed using a host‑side entry script located in `ct/`, with the actual installation logic running inside the container via scripts in `install/`.

This repository currently contains the **Hermes Dev** installer, with support for additional applications planned.

---

## Repository Structure

```text
ProxmoxVED/
  ct/
    hermes-dev.sh            # Host-side entry script (curl-installable)
  install/
    hermes-dev-install.sh    # Inside-container installer
  misc/
    build.func               # Shared helper functions (Community-Scripts style)
```

- **ct/**  
  Contains host-side entry scripts.  
  These scripts:
  - Build the LXC container  
  - Push the inside-container installer  
  - Execute the installer  
  - Provide update support via `update_script()`  

- **install/**  
  Contains inside-container installers.  
  These scripts:
  - Install the application inside the LXC  
  - Create `/etc/<app>/install.conf`  
  - Create `/usr/bin/update` inside the container  
  - Implement unified install/update logic  

- **misc/**  
  Contains shared helper functions used by `ct/*.sh`.

---

## Installing Hermes Dev

You can install Hermes Dev directly from this repository using:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/TCBWZA/ProxmoxVED/ct/hermes-dev.sh)"
