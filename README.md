# 🧬 JuliaDeconVolution (CPU Edition)

![Julia](https://img.shields.io/badge/Julia-1.10+-9558B2?logo=julia&logoColor=white)
![CPU](https://img.shields.io/badge/Compute-CPU%20Only-blue)
![FFTW](https://img.shields.io/badge/FFT-FFTW.jl-orange)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 🧪 CPU-Only 3D Fluorescence Deconvolution in Julia

An **interactive, open-source, CPU-only 3D fluorescence microscopy deconvolution platform** built in Julia.

This version provides a high-performance, locally hosted alternative to commercial deconvolution tools, specifically optimized for multi-channel TIFF stacks — **without requiring a GPU**.

> ⚠️ This version runs entirely on CPU using system RAM and multi-threaded FFTW.jl acceleration.

---

## ✨ Key Features

### 🖥️ Universal Compatibility
Runs on any system:
- Windows
- Linux
- macOS  
No NVIDIA GPU or CUDA required.

---

### 🎛️ Interactive Visualization
Built with `GLMakie` for real-time side-by-side visualization of raw and deconvolved Z-stacks.

---

### 🔬 True 3D Deconvolution
Implements a custom **Richardson–Lucy Maximum Likelihood Estimation (MLE)** algorithm to recover fine biological structures while minimizing ringing artifacts.

---

### 📡 Physics-Based PSF Modeling
Automatically computes a **dynamic Point Spread Function (PSF)** based on microscope parameters:

- Numerical Aperture (NA)  
- Refractive Index (RI)  
- Emission Wavelength (λ)  
- Voxel dimensions (XY & Z step)

---

### 🧠 Smart Data Handling
- Automatic conversion of flat TIFF stacks into structured 3D hyperstacks  
- Multi-channel support (DAPI / FITC / TRITC, etc.)

---

## 💻 System Requirements

| Component | Requirement |
|----------|-------------|
| OS | Windows / Linux / macOS |
| CPU | Multi-core processor (i5 / Ryzen 5 or better recommended) |
| RAM | 16 GB+ recommended (large 3D FFT operations are memory intensive) |
| Julia | ≥ 1.10 |

---

## 🚀 Installation & Setup

### 1. Clone Repository

```bash
git clone https://github.com/YourUsername/JuliaDeconVolution_in_CPU.git
cd JuliaDeconVolution_in_CPU
```

---

### 2. Initialize Julia Environment

```bash
julia
```

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```

---

## ▶️ How to Run

Start the application from terminal or Julia REPL:

```julia
include("run.jl")
```

---

## 🧭 Workflow Guide

### 1. Load Data
Click **Open TIFF** and select your multi-channel Z-stack.  
The UI automatically adapts to Z-depth.

---

### 2. Select Channel
Choose from:
- DAPI
- FITC
- TRITC
- Custom

---

### 3. Configure Optical Parameters
Adjust:
- Numerical Aperture (NA)
- Refractive Index (RI)
- XY pixel size
- Z-step size

---

### 4. Set Iterations

| Iterations | Use Case |
|------------|----------|
| 10–15 | Recommended default (CPU-balanced) |
| 25+ | High sharpening (slow on CPU) |

---

### 5. Run Deconvolution
Click **Run CPU Deconvolution**:

The pipeline will:
- Compute Optical Transfer Function (OTF)
- Run FFTW-based Richardson–Lucy iterations
- Process using multi-threaded CPU execution
- Stream progress in console

---

### 6. Export Results
Save reconstructed 3D volume as high-bit-depth TIFF for downstream analysis.

---

## 📁 Project Architecture

```
MicroscopyLabPlatform_CPU_Compatible/
│
├── Project.toml
├── run.jl
│
└── src/
    ├── MicroscopyLabPlatform.jl
    │
    ├── GUI/
    ├── IO/
    ├── PSF/
    ├── Utils/
    │
    └── Algorithms/
        ├── RichardsonLucyCPU.jl
        └── DeconvOptimCPU.jl
```

---

## ⚠️ Troubleshooting

### Slow Performance
- Increase Julia threads:
```bash
set JULIA_NUM_THREADS=8
```

---

### Memory Issues (RAM overflow)
- Reduce stack size
- Reduce PSF kernel size
- Downsample input TIFF

---

### Unexpected TIFF Dimensions
Expected format:
```
X × Y × (Channels × Z)
```

Adjust parsing logic in:
```
src/IO/TIFFLoader.jl
```

---

## 📝 License

This project is licensed under the MIT License.

---
