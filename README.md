# ComfyUI Docker Container

A containerized version of ComfyUI, a powerful node-based interface for Stable Diffusion image generation. This Docker setup provides a complete environment for running ComfyUI with GPU acceleration and pre-installed custom nodes.

## Overview

ComfyUI is a powerful and flexible interface for Stable Diffusion that uses a node-based workflow system. This Docker container includes:

- **GPU Acceleration**: Built on NVIDIA CUDA 13.0 for optimal performance.
- **Pre-installed Custom Nodes**: ComfyUI Manager, X-Flux, and ControlNet Auxiliary nodes.
- **Optimized Python Environment**: Python 3.12 with all necessary dependencies.
- **Ready-to-use**: No additional setup required after building.

## Custom Nodes Included

- **ComfyUI Manager**: Model management and installation.
- **X-Flux**: Advanced image generation features.
- **ControlNet Auxiliary**: Various ControlNet implementations.

## Prerequisites

- Docker and Docker Compose installed.
- NVIDIA GPU with CUDA 13.0+ compatibility, tested with NVIDIA GeForce RTX 5090.
- At least 16GB of available RAM.
- Recommended to have at least 20GB+ of free disk space for models.

## Quick Start

### 1. Create Data Directories

```bash
mkdir -p data/input data/models data/output
```

### 2. Build and Start the Container

```bash
docker compose up -d --build
```

### 3. Access ComfyUI

Open your web browser and navigate to `http://localhost:8188`

## Configuration

### Port Exposure

The container uses Docker Compose override files for flexible port configuration:

- **Example**: Port 8188 is exposed via `docker-compose.override-example.yml`
- **Custom Port**: Copy the file to `docker-compose.override.yml` to change the port.
- **No Port Exposure**: This is the default behavior.

### Custom Port Example

To use a different port, copy and edit `docker-compose.override.yml`:

```yaml
services:
  comfyui:
    ports:
      - "9000:8188"  # Access via http://localhost:9000
```

## Data Directory Structure

```
data/
├── models/          # Stable Diffusion models, LoRAs, VAEs.
├── input/           # Input images for processing.
└── output/          # Generated images.
```

## Downloading Models

### Using ComfyUI Manager (Recommended)

1. Access the web interface at `http://localhost:8188`
2. Navigate to the "Manager" tab.
3. Browse and download models directly from the interface.

### Manual Download

Place your models in the appropriate directories:

- **Stable Diffusion Models**: `data/models/checkpoints/`
- **LoRA Models**: `data/models/loras/`
- **VAE Models**: `data/models/vae/`

## Usage

1. **Load a Model**: Use ComfyUI Manager or drag and drop checkpoint files.
2. **Create a Workflow**: Use the node-based interface to create your generation pipeline.
3. **Generate Images**: Connect nodes and click "Queue Prompt" to generate images.
4. **Save Workflows**: Save your workflows for future use.
