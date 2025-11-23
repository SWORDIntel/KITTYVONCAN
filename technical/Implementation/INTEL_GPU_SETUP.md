# Intel GPU Setup for AI Engine

**Date:** 2025-11-22
**System:** Dell Latitude 5450 with Intel Arc Graphics (Meteor Lake-P)
**Status:** ⚠️ CONFIGURATION REQUIRED

---

## Current Status

### Hardware Detected

**Intel Arc Graphics (Integrated)**
- Device: Intel Corporation Meteor Lake-P [Intel Arc Graphics]
- PCI ID: 0000:00:02.0
- Device ID: 8086:7d55
- Architecture: Xe-HPG (same as discrete Arc GPUs)
- Compute Units: 128
- INT8 TOPS: ~40
- Memory: Shared system RAM (55.8 GB usable)

**FLEX GPU (Discrete)**
- Status: ❌ Not present
- Note: System has integrated GPU only

### Software Status

**DRI Devices:** ✅ Available
```
/dev/dri/card0       - Display device
/dev/dri/renderD128  - Compute device
```

**User Permissions:** ✅ Configured
- User 'john' is in 'render' group
- Can access GPU compute device

**PyTorch:** ⚠️ No GPU Support
- Version: 2.9.1+cu128 (CUDA build, not Intel)
- CUDA available: False
- XPU available: False (Intel GPU backend not active)

**Intel Extension for PyTorch (IPEX):** ❌ Not Installed
- Required for Intel GPU compute
- Provides XPU backend to PyTorch

---

## Required Components

### 1. Intel GPU Drivers

**Status:** ✅ Likely Present (system boots with Arc GPU)

**Verify:**
```bash
lsmod | grep -E "i915|xe"
```

Expected: `i915` kernel module loaded

---

### 2. Intel Compute Runtime

**Components Needed:**
- `intel-level-zero-gpu` - Level Zero API for compute
- `intel-opencl-icd` - OpenCL support
- `libze1` - Level Zero libraries

**Install:**
```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install -y \
    intel-level-zero-gpu \
    intel-opencl-icd \
    level-zero-dev \
    libze1
```

---

### 3. Intel Extension for PyTorch (IPEX)

**Purpose:** Enables PyTorch to use Intel GPUs via XPU backend

**Install:**
```bash
# Activate venv
source /home/john/Documents/LAT5150DRVMIL/.venv/bin/activate

# Install IPEX for XPU (Intel GPU support)
python3 -m pip install intel-extension-for-pytorch
```

**Note:** IPEX version must match PyTorch version (currently 2.9.x)

---

## Setup Procedure

### Step 1: Install Intel Compute Runtime

```bash
# Install Level Zero and OpenCL runtimes
sudo apt-get update
sudo apt-get install -y \
    intel-level-zero-gpu \
    intel-opencl-icd \
    level-zero-dev \
    libze1

# Verify Level Zero installation
ls -la /usr/lib/x86_64-linux-gnu/libze_loader.so*
```

Expected: Level Zero libraries present

---

### Step 2: Verify GPU Access

```bash
# Check render device permissions
ls -la /dev/dri/renderD128

# Should show:
# crw-rw----+ 1 root render 226, 128 ...

# Verify user in render group
groups | grep render
```

---

### Step 3: Install Intel Extension for PyTorch

```bash
# Activate Python virtual environment
cd /home/john/Documents/LAT5150DRVMIL
source .venv/bin/activate

# Install IPEX
pip install intel-extension-for-pytorch

# Or specify version matching PyTorch
# pip install intel-extension-for-pytorch==2.9.1
```

---

### Step 4: Verify XPU Backend

```bash
# Test XPU availability
python3 << 'EOF'
import torch
import intel_extension_for_pytorch as ipex

print(f"PyTorch version: {torch.__version__}")
print(f"IPEX version: {ipex.__version__}")
print(f"XPU available: {torch.xpu.is_available()}")

if torch.xpu.is_available():
    print(f"XPU device count: {torch.xpu.device_count()}")
    print(f"XPU device name: {torch.xpu.get_device_name(0)}")
    print(f"XPU device properties: {torch.xpu.get_device_properties(0)}")
else:
    print("XPU not available - check Level Zero installation")
EOF
```

**Expected Output:**
```
PyTorch version: 2.9.1+cu128
IPEX version: 2.9.1
XPU available: True
XPU device count: 1
XPU device name: Intel(R) Arc(TM) Graphics
```

---

### Step 5: Update AI Engine Configuration

Once XPU is available, the AI engine needs to be configured to use it.

**File:** `/home/john/Documents/LAT5150DRVMIL/02-ai-engine/src/config/hardware_profile.json`

Verify these settings:
```json
{
  "arc_gpu_available": true,
  "arc_gpu_shared_ram": true,
  "arc_gpu_usable_gb": 55.8,
  "arc_gpu_tops_int8": 40.0,
  "arc_gpu_compute_units": 128
}
```

---

## AI Engine Integration

### Device Detection

The AI engine has Intel GPU detection code:

**File:** `/home/john/Documents/LAT5150DRVMIL/02-ai-engine/src/hardware/flex_gpu_detector.py`

**Purpose:** Detects discrete FLEX GPUs (Flex 140/170)

**Current Result:** No discrete GPU (only integrated)

---

### Workload Router

**File:** `/home/john/Documents/LAT5150DRVMIL/02-ai-engine/src/hardware/flex_workload_router.py`

**Purpose:** Routes workloads between discrete FLEX GPU and integrated GPU

**Current Configuration:**
- Discrete FLEX GPU: ❌ Not available
- Integrated GPU: ✅ Available
- All workloads → Integrated GPU

---

### Using XPU in AI Engine

Once IPEX is installed, AI models can use the Intel GPU:

```python
import torch
import intel_extension_for_pytorch as ipex

# Move model to XPU device
device = torch.device("xpu:0")
model = model.to(device)

# Move tensors to XPU
input_tensor = input_tensor.to(device)

# Run inference on GPU
with torch.no_grad():
    output = model(input_tensor)
```

---

## Performance Expectations

### Intel Arc Graphics (Meteor Lake-P)

**Specifications:**
- INT8 TOPS: ~40
- FP16 TFLOPS: ~5
- Memory Bandwidth: Shared (system RAM)
- Compute Units: 128 Xe cores

**Expected Performance:**
- Small model inference (< 7B params): ✅ Good
- Medium models (7B-13B params): ⚠️ Moderate (memory bandwidth limited)
- Large models (> 13B params): ❌ Poor (insufficient memory bandwidth)

**Best Use Cases:**
- Stable Diffusion / image generation
- Small language models (< 3B params)
- Image classification / object detection
- Video analysis (integrated media engine)
- Embedding generation

---

## Comparison: Integrated vs Discrete FLEX

### Integrated Arc GPU (Current)
- Memory: Shared system RAM (55.8 GB)
- Bandwidth: ~68 GB/s (system memory)
- INT8 TOPS: ~40
- Power: ~15W
- Best for: Mixed workloads, media, small inference

### FLEX 140 (Not Present)
- Memory: 12GB GDDR6 dedicated
- Bandwidth: 204 GB/s
- INT8 TOPS: 133.2
- Power: 75W
- Best for: Inference-only workloads

**Key Difference:** FLEX 140 has 3x bandwidth and 3x compute, but integrated GPU can access full system RAM.

---

## Troubleshooting

### Issue: XPU not available after IPEX install

**Check Level Zero:**
```bash
# Install Level Zero
sudo apt-get install intel-level-zero-gpu

# Verify device
ls -la /dev/dri/renderD128
```

---

### Issue: Permission denied accessing GPU

**Fix:**
```bash
# Add user to render group
sudo usermod -aG render john

# Log out and back in, or:
newgrp render
```

---

### Issue: Level Zero libraries not found

**Fix:**
```bash
# Install Level Zero development package
sudo apt-get install level-zero-dev libze1

# Set library path
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
```

---

### Issue: IPEX version mismatch

**Symptom:** `RuntimeError: IPEX version mismatch`

**Fix:**
```bash
# Install matching IPEX version
pip install intel-extension-for-pytorch==2.9.1

# Or reinstall both
pip uninstall torch intel-extension-for-pytorch
pip install torch==2.9.1 intel-extension-for-pytorch==2.9.1
```

---

## Testing GPU Compute

### Simple Test Script

**File:** `test_intel_gpu.py`

```python
#!/usr/bin/env python3
"""Test Intel GPU compute via XPU backend"""

import torch
import intel_extension_for_pytorch as ipex

print("="*60)
print("Intel XPU (GPU) Test")
print("="*60)

# Check XPU availability
xpu_available = torch.xpu.is_available()
print(f"\nXPU Available: {xpu_available}")

if not xpu_available:
    print("❌ XPU not available")
    print("   Install: pip install intel-extension-for-pytorch")
    exit(1)

# Get device info
device_count = torch.xpu.device_count()
print(f"XPU Device Count: {device_count}")

for i in range(device_count):
    device_name = torch.xpu.get_device_name(i)
    print(f"\nDevice {i}: {device_name}")

    props = torch.xpu.get_device_properties(i)
    print(f"  Max compute units: {props.max_compute_units}")
    print(f"  Max work group size: {props.max_work_group_size}")

# Run simple compute test
print("\n" + "="*60)
print("Running Compute Test...")
print("="*60)

device = torch.device("xpu:0")

# Create test tensors
size = 4096
a = torch.randn(size, size).to(device)
b = torch.randn(size, size).to(device)

# Matrix multiplication on GPU
import time
start = time.time()
c = torch.matmul(a, b)
torch.xpu.synchronize()  # Wait for GPU to finish
elapsed = time.time() - start

print(f"\nMatrix multiplication ({size}x{size}):")
print(f"  Time: {elapsed*1000:.2f} ms")
print(f"  GFLOPS: {2 * size**3 / elapsed / 1e9:.2f}")

print("\n✅ Intel GPU compute working correctly")
print("="*60)
```

**Run:**
```bash
python3 test_intel_gpu.py
```

---

## Next Steps

### 1. Install Intel Compute Runtime

```bash
sudo apt-get install -y intel-level-zero-gpu intel-opencl-icd level-zero-dev libze1
```

### 2. Install IPEX

```bash
source /home/john/Documents/LAT5150DRVMIL/.venv/bin/activate
pip install intel-extension-for-pytorch
```

### 3. Verify Setup

```bash
python3 -c "import torch, intel_extension_for_pytorch as ipex; print(f'XPU: {torch.xpu.is_available()}')"
```

### 4. Update AI Engine

Modify inference code to use `device="xpu:0"` instead of `device="cpu"`

### 5. Test Performance

Run inference benchmarks comparing CPU vs XPU performance

---

## References

**Intel Extension for PyTorch:**
- https://github.com/intel/intel-extension-for-pytorch
- https://intel.github.io/intel-extension-for-pytorch/

**Level Zero:**
- https://github.com/oneapi-src/level-zero

**Intel Arc Graphics:**
- Architecture: Xe-HPG (same as Arc A-series discrete GPUs)
- Compute API: Level Zero, OpenCL, SYCL

---

**Classification:** NATO UNCLASSIFIED (EXERCISE)
**Date:** 2025-11-22
**Status:** ⚠️ SETUP REQUIRED
**Next Action:** Install Intel compute runtime and IPEX
