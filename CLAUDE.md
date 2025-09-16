# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

LeRobot is a state-of-the-art robotics library for real-world robotics in PyTorch, developed by Hugging Face. It provides models, datasets, and tools for imitation learning and reinforcement learning on both simulated and real robots.

## Development Commands

### Installation
```bash
# Install in editable mode (recommended for development)
pip install -e .

# Install with specific robot/environment support
pip install -e ".[aloha,pusht,xarm]"

# Install all optional dependencies
pip install -e ".[all]"
```

### Core Commands
```bash
# Training a policy
lerobot-train --config_path=path/to/config

# Evaluating a policy
lerobot-eval --policy.path=path/to/model

# Recording robot demonstrations
lerobot-record

# Replaying recorded data
lerobot-replay

# Hardware setup utilities
lerobot-calibrate
lerobot-find-cameras
lerobot-find-port
lerobot-setup-motors
lerobot-teleoperate
```

### Testing
```bash
# Run end-to-end tests (from Makefile)
make test-end-to-end

# Run specific policy tests
make test-act-ete-train
make test-diffusion-ete-train
make test-tdmpc-ete-train
make test-smolvla-ete-train

# Run with specific device
make DEVICE=cuda test-end-to-end
```

### Code Quality
The project uses pre-commit hooks configured in `.pre-commit-config.yaml`:
```bash
# Install pre-commit hooks
pre-commit install

# Run pre-commit on all files
pre-commit run --all-files

# Manual linting/formatting
ruff format .
ruff check --fix .
```

### Dataset Visualization
```bash
# Visualize a dataset from Hugging Face Hub
python -m lerobot.scripts.visualize_dataset --repo-id lerobot/pusht --episode-index 0

# Visualize local dataset
python -m lerobot.scripts.visualize_dataset --repo-id lerobot/pusht --root ./data --local-files-only 1
```

## Architecture

### Core Structure
- **`src/lerobot/`**: Main source code
  - **`policies/`**: Implementation of different RL/IL policies (ACT, Diffusion, TDMPC, SmolVLA, etc.)
  - **`robots/`**: Robot-specific implementations and control interfaces
  - **`cameras/`**: Camera interfaces and capture utilities
  - **`motors/`**: Motor control abstractions (Dynamixel, Feetech, etc.)
  - **`datasets/`**: Dataset loading, processing, and conversion utilities
  - **`envs/`**: Simulation environment integrations (gym-aloha, gym-pusht, gym-xarm)
  - **`teleoperators/`**: Teleoperation interfaces for different input devices
  - **`scripts/`**: Main training and evaluation scripts
  - **`utils/`**: Shared utilities for visualization, I/O, training, etc.

### Key Concepts

**LeRobotDataset Format**: A standardized dataset format that stores:
- Robot states and actions as tensors
- Camera streams as compressed MP4 videos
- Episode metadata and statistics
- Compatible with Hugging Face Hub for easy sharing

**Policy Architecture**: Modular policy implementations supporting:
- Imitation Learning (ACT, Diffusion Policy, VQ-BeT)
- Reinforcement Learning (TDMPC)
- Vision-Language Models (SmolVLA, Pi0)

**Robot Abstraction**: Unified interfaces for:
- Different motor types (Dynamixel, Feetech servos)
- Various camera systems (OpenCV, Intel RealSense)
- Teleoperation devices (keyboards, game controllers, leader-follower arms)

### Configuration System
Uses `draccus` for configuration management:
- Policy configs in `src/lerobot/configs/`
- Environment-specific settings
- Training hyperparameters and device selection
- Modular composition of components

## Hardware Support

**Supported Robots**:
- **SO-101**: Low-cost robotic arm (€114 per arm)
- **HopeJR**: Humanoid robot arm with dexterous hand
- **LeKiwi**: Mobile robot platform
- **ALOHA**: Bimanual manipulation setup
- **Reachy2**: Advanced humanoid robot

**Motor Controllers**: Dynamixel, Feetech servos
**Cameras**: OpenCV-compatible, Intel RealSense
**Input Devices**: Keyboards, gamepads, teleoperation arms

## Training Workflows

1. **Data Collection**: Use `lerobot-record` with teleoperation
2. **Dataset Preparation**: Convert to LeRobotDataset format
3. **Policy Training**: Run `lerobot-train` with appropriate config
4. **Evaluation**: Test with `lerobot-eval` in simulation or real robot
5. **Model Sharing**: Push trained models to Hugging Face Hub

## Important Notes

- The codebase requires Python 3.10+ and PyTorch 2.2+
- FFmpeg with libsvtav1 support is required for video processing
- WandB integration available for experiment tracking (`wandb login`)
- Pre-trained models available on [huggingface.co/lerobot](https://huggingface.co/lerobot)
- Use `make` commands for comprehensive testing of policy implementations