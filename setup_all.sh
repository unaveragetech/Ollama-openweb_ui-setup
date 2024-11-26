#!/bin/bash

# Function to check for command success
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error occurred during $1. Exiting."
        exit 1
    fi
}

# Step 1: System update and upgrade
echo "Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y
check_success "system update"

# Step 2: Install NVIDIA driver, CUDA toolkit, and GPU monitoring tools (for older systems)
echo "Installing NVIDIA driver (for older systems)..."
sudo apt install -y nvidia-driver-535
check_success "NVIDIA driver installation"

# Verify Direct Rendering
echo "Verifying GPU direct rendering..."
glxinfo | grep "direct rendering"
check_success "Direct rendering verification"

# Install NVIDIA CUDA Toolkit
echo "Installing NVIDIA CUDA Toolkit..."
sudo apt install -y nvidia-cuda-toolkit
check_success "NVIDIA CUDA Toolkit installation"

# Verify CUDA installation
echo "Verifying CUDA installation..."
nvcc --version
check_success "CUDA version check"

# Install NVTOP for GPU monitoring
echo "Installing NVTOP for GPU monitoring..."
sudo apt install -y nvtop
check_success "NVTOP installation"

# Step 3: Install Ollama
echo "Installing Ollama..."
curl -fsSL https://ollama.com/install.sh | sh
check_success "Ollama installation"

# Prompt for model selection
echo "Enter the model you want to use (default is llama3:8b): "
read MODEL_NAME
MODEL_NAME=${MODEL_NAME:-llama3:8b}  # Default to llama3:8b if no input is given
echo "Using model: $MODEL_NAME"

# Step 4: Add and pull the specified model
echo "Adding model $MODEL_NAME to Ollama..."
ollama pull $MODEL_NAME
check_success "Model $MODEL_NAME pull"

# Run the model using Ollama (example request)
echo "Sending prompt to Ollama API..."
curl -X POST http://localhost:11434/api/generate -d '{
  "model": "'$MODEL_NAME'",
  "prompt":"Write a sentence about Linux",
  "stream": false 
}' | jq
check_success "Ollama model API request"

# Step 5: Docker installation (for Open WebUI)
echo "Installing Docker..."
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

echo "Installing Docker components..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
check_success "Docker installation"

# Step 6: Run Open WebUI Docker container
echo "Enter the port number for Open WebUI (default is 8080):"
read PORT
PORT=${PORT:-8080}  # Default to 8080 if no input is given
echo "Using port: $PORT"

echo "Running Open WebUI Docker container on port $PORT..."
sudo docker run -d --network=host --gpus all -v open-webui:/app/backend/data -e OLLAMA_BASE_URL=http://127.0.0.1:11434 -e PORT=$PORT --name open-webui --restart always ghcr.io/open-webui/open-webui:cuda
check_success "Open WebUI Docker container setup"

# Step 7: Handle port conflicts and container renaming if necessary
echo "If port $PORT is already in use, stopping and renaming the existing container..."
sudo docker stop open-webui
sudo docker rename open-webui open-webui-old
check_success "Renaming existing Open WebUI container"

# Step 8: Build custom Open WebUI container if needed
echo "Building custom Open WebUI container..."
sudo docker build -t open-webui-custom .
check_success "Custom Open WebUI container build"

# Step 9: Stable Diffusion prerequisites
echo "Installing Stable Diffusion prerequisites..."
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev git
check_success "Stable Diffusion prerequisites installation"

# Step 10: Install Pyenv
echo "Installing Pyenv..."
curl https://pyenv.run | bash
check_success "Pyenv installation"

# Update PATH for Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# Step 11: Install Python 3.10 via Pyenv
echo "Installing Python 3.10 via Pyenv..."
pyenv install 3.10
pyenv global 3.10
check_success "Python 3.10 installation"

# Step 12: Install Stable Diffusion Web UI
echo "Downloading Stable Diffusion setup..."
wget -q https://raw.githubusercontent.com/AUTOMATIC1111/stable-diffusion-webui/master/webui.sh
chmod +x webui.sh

echo "Running Stable Diffusion..."
./webui.sh --listen --api
check_success "Stable Diffusion setup"

echo "Setup completed successfully!"
