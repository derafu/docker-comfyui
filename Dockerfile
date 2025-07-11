# ComfyUI Docker Image
# This Dockerfile creates a containerized environment for ComfyUI, a powerful node-based UI for Stable Diffusion.
# Based on NVIDIA CUDA 12.8.0 for GPU acceleration support.

FROM nvidia/cuda:12.8.0-base-ubuntu22.04

# Set environment variables for non-interactive installation and Python version.
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHON_VERSION=3.12.3 \
    TZ=UTC

# Install system dependencies required for ComfyUI and its components.
# This includes build tools, Python, OpenCV dependencies, and other essential packages.
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    python3-pip \
    python3-venv \
    ffmpeg \
    git-lfs \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    libffi-dev \
    liblzma-dev \
    tk-dev \
    uuid-dev \
    && git lfs install && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set the working directory for ComfyUI installation.
WORKDIR /opt/comfyui

# Install Python 3.12 from source for optimal performance.
# This ensures we have the latest Python version with all optimizations enabled.
RUN curl -LO https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make -j"$(nproc)" && \
    make altinstall && \
    cd .. && \
    rm -rf Python-${PYTHON_VERSION}*

# Create symbolic links to make Python 3.12 the default python3 and pip3.
RUN ln -sf /usr/local/bin/python3.12 /usr/bin/python3 && \
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip3

# Clone and install ComfyUI with PyTorch and CUDA support.
# This installs the core ComfyUI application with GPU acceleration.
RUN git clone https://github.com/comfyanonymous/ComfyUI . && \
    pip install --upgrade pip && \
    pip install --no-cache-dir torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu128 && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install xformers!=0.0.18 -f https://download.pytorch.org/whl/cu128

# Install ComfyUI Manager - a plugin for managing models and custom nodes.
# This provides a user-friendly interface for downloading and managing models.
RUN cd /opt/comfyui/custom_nodes && \
    git clone https://github.com/ltdrdata/ComfyUI-Manager comfyui-manager

# Install X-Flux custom node for advanced image generation features.
# This adds additional capabilities for image generation and manipulation.
RUN cd /opt/comfyui/custom_nodes && \
    git clone https://github.com/XLabs-AI/x-flux-comfyui.git && \
    cd x-flux-comfyui && \
    python3.12 setup.py

# Install ControlNet Auxiliary nodes for advanced image control.
# This enables various ControlNet features for precise image generation control.
RUN cd /opt/comfyui/custom_nodes && \
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux && \
    cd comfyui_controlnet_aux && \
    pip3.12 install -r requirements.txt

# Replace CPU-only ONNX Runtime with GPU-accelerated version.
# This ensures DWPose models use GPU acceleration instead of CPU for better performance.
RUN pip3.12 uninstall -y onnxruntime && \
    pip3.12 install onnxruntime-gpu

# Note: Model downloads should be handled by the host system.
# The following commented section shows how to download a default model.
# It's recommended to download models externally and mount them as volumes.
#RUN mkdir -p models/checkpoints && \
#    wget -c https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors -P models/checkpoints/

# Expose the default ComfyUI web interface port.
EXPOSE 8188

# Start ComfyUI with optimized settings for containerized environment.
# --use-pytorch-cross-attention: Enables optimized attention mechanisms.
# --listen 0.0.0.0: Binds to all interfaces for container access.
# --port 8188: Uses the standard ComfyUI port.
CMD ["python3", "/opt/comfyui/main.py", "--use-pytorch-cross-attention", "--listen", "0.0.0.0", "--port", "8188"]
