# Intel GPU Driver & Runtime Installation Guide (Build from Source)

**Objective:** This guide provides a condensed set of instructions to build and install the Intel Graphics Compiler (IGC) and Intel Compute Runtime from source, and to configure the Python environment for Intel GPUs (XPU).

**Prerequisites:**
*   All necessary source code repositories (`igc`, `llvm-project`, `vc-intrinsics`, `SPIRV-Tools`, `SPIRV-Headers`, `opencl-clang`, `SPIRV-LLVM-Translator`, `compute-runtime`) are assumed to be cloned into `~/igc_workspace` and `~/intel-compute-runtime-build` respectively.
*   Build dependencies (e.g., `git`, `cmake`, `build-essential`, `clang`, `gcc-12`, `g++-12`, `python3-mako`) are assumed to be installed.
*   Global `git` credentials (`user.name`, `user.email`) are configured.

---

### **Step 1: Build and Install Intel Graphics Compiler (IGC)**

This step compiles and installs the Intel Graphics Compiler (IGC), which is a prerequisite for building the main Intel Compute Runtime. This uses the `gcc-12` and `g++-12` compilers to ensure compatibility.

```bash
cd ~/igc_workspace && \
rm -rf build && \
mkdir build && \
cd build && \
cmake -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 -DCMAKE_CXX_STANDARD=17 ../igc && \
make -j$(nproc) && \
sudo make install
```

---

### **Step 2: Build and Install Intel Compute Runtime**

With the Intel Graphics Compiler (IGC) installed, this step compiles and installs the main Intel Compute Runtime. This runtime is essential for the Intel GPU (XPU) to be properly recognized and utilized by applications, including PyTorch.

```bash
cd ~/intel-compute-runtime-build && \
rm -rf build && \
mkdir build && \
cd build && \
cmake -DCMAKE_C_COMPILER=gcc-12 -DCMAKE_CXX_COMPILER=g++-12 -DCMAKE_BUILD_TYPE=Release ../neo && \
make -j$(nproc) && \
sudo make install
```

---

### **Step 3: Install Intel Extension for PyTorch (IPEX)**

This step installs the specific PyTorch extension that enables PyTorch to communicate with and leverage the Intel GPU (XPU) for AI workloads.

```bash
pip install intel-extension-for-pytorch
```

---

### **Step 4: Final Verification**

Execute the following Python script to confirm that the Intel GPU is now correctly recognized and accessible within your PyTorch environment.

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

---
