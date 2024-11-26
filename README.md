# Ollama Open WebUI Setup

This repository provides a comprehensive script to set up **Ollama**, **Open WebUI**, and **Stable Diffusion** with GPU support, as well as integrating the necessary configurations for running various AI models. The script handles installations, model pulls, Docker setups, and more.

## Features:
- **Ollama Installation**: Installs Ollama and pulls the specified model (default is `llama3:8b`).
- **GPU Support**: Configures NVIDIA drivers, CUDA toolkit, and uses Docker to run Open WebUI with GPU support.
- **Docker Container for Open WebUI**: Runs Open WebUI in a Docker container and provides an option to configure the port.
- **Stable Diffusion Setup**: Installs all necessary prerequisites for Stable Diffusion and sets up its web UI.
- **Model Customization**: Allows you to specify which model to use with Ollama and provides automatic configuration for different environments.

## Prerequisites:
- **Linux or Windows Subsystem for Linux (WSL)** with Ubuntu.
- **NVIDIA GPU** (optional, but required for GPU support).
- **Docker** installed on the system.
- **Python** (required for Stable Diffusion setup).
- **Git** to clone the repository.

## Installation:

### 1. Clone the repository

Clone this repository to your local machine:

```bash
git clone https://github.com/unaveragetech/Ollama-openweb_ui-setup.git
cd Ollama-openweb_ui-setup
```

### 2. Make the script executable

Ensure the script is executable by running:

```bash
chmod +x setup_all.sh
```

### 3. Run the setup script

Execute the setup script to install all dependencies, configure Docker, and pull the required models.

```bash
./setup_all.sh
```

### 4. Configuration Options

- **Model Selection**: During setup, you’ll be prompted to enter the model you want to use. If you press enter without entering anything, it will default to `llama3:8b`.
- **Port Selection**: You can specify a custom port for Open WebUI during the setup (default is `8080`). If the port is in use, the script will handle renaming the existing Docker container to avoid conflicts.

### 5. Verify the installation

Once the script completes, the Open WebUI should be accessible at `http://localhost:8080` (or the port you specified during setup).

## Troubleshooting:
- If you encounter any errors related to Docker or NVIDIA drivers, make sure your system meets the **prerequisites** and that your GPU drivers are properly installed.
- If the port you selected is already in use, the script will stop and rename the existing Docker container to avoid conflicts.
- To verify the GPU setup, you can run `glxinfo | grep "direct rendering"` to check if direct rendering is enabled.

## Docker Container Management:

- **Stop Open WebUI**:
  ```bash
  sudo docker stop open-webui
  ```
- **Rename Open WebUI Container** (if port conflict occurs):
  ```bash
  sudo docker rename open-webui open-webui-old
  ```
- **Build Custom Docker Image**:
  If you need to build a custom Docker image for Open WebUI, run:
  ```bash
  sudo docker build -t open-webui-custom .
  ```

## Uninstallation:

If you need to remove the setup, you can remove the Docker container and images manually:

1. **Stop and remove Docker container**:
   ```bash
   sudo docker stop open-webui
   sudo docker rm open-webui
   ```

2. **Remove Docker image**:
   ```bash
   sudo docker rmi ghcr.io/open-webui/open-webui:cuda
   ```

3. **Uninstall Ollama**:
   ```bash
   curl -fsSL https://ollama.com/uninstall.sh | sh
   ```

