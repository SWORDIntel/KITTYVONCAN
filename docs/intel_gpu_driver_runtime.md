# Intel GPU Driver & Runtime Installation Guide (Build from Source)

This guide condenses the steps to build and install the Intel Graphics Compiler (IGC) and Intel Compute Runtime from source, and to configure Python for Intel GPUs (XPU). It assumes the required repositories already exist in the paths shown below.

## Prerequisites
- Repositories cloned to `~/igc_workspace` (IGC stack) and `~/intel-compute-runtime-build` (Compute Runtime)
- Build dependencies installed (`git`, `cmake`, `build-essential`, `clang`, `gcc-12`, `g++-12`, `python3-mako`, etc.)
- Global git configuration set (`user.name`, `user.email`)

## Step 1: Build and Install Intel Graphics Compiler (IGC)

Compile and install IGC (prerequisite for the runtime) using `gcc-12` and `g++-12` for compatibility:

```bash
cd ~/igc_workspace && \
rm -rf build && \
mkdir build && \
cd build && \
cmake -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 -DCMAKE_CXX_STANDARD=17 ../igc && \
make -j$(nproc) && \
sudo make install
```

## Step 2: Build and Install Intel Compute Runtime

With IGC installed, compile and install the main Intel Compute Runtime:

```bash
cd ~/intel-compute-runtime-build && \
rm -rf build && \
mkdir build && \
cd build && \
cmake -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 -DCMAKE_BUILD_TYPE=Release ../neo && \
make -j$(nproc) && \
sudo make install
```

## Step 3: Install Intel Extension for PyTorch (IPEX)

Install the PyTorch extension that enables XPU support:

```bash
pip install intel-extension-for-pytorch
```

## Step 4: Final Verification

Use the script below to confirm that PyTorch detects the Intel GPU (XPU):

```python
#!/usr/bin/env python3
"""Verify Intel GPU (XPU) availability in PyTorch"""

import torch
import intel_extension_for_pytorch as ipex

print("="*60)
print("Intel XPU (GPU) Setup Verification")
print("="*60)

print(f"\nPyTorch version: {torch.__version__}")
print(f"IPEX version: {ipex.__version__}")

# Check XPU availability
xpu_available = torch.xpu.is_available()
print(f"\nXPU Available: {xpu_available}")

if xpu_available:
    print("\nSUCCESS: Intel GPU (XPU) is available for PyTorch.")
    print(f"  XPU device count: {torch.xpu.device_count()}")
    print(f"  XPU device name: {torch.xpu.get_device_name(0)}")
    print(f"  XPU device properties: {torch.xpu.get_device_properties(0)}")
else:
    print("\nFAILURE: Intel GPU (XPU) not available for PyTorch.")
    print("  Please review the build and installation logs for any errors.")
    print("  Ensure all previous steps were completed successfully.")

print("\n" + "="*60)
```
