# BalVOX — Wicked Engine Edition

BalVOX is migrating to [Wicked Engine](https://github.com/turanszkij/WickedEngine), a C++ 3D engine with DirectX 12 on Windows and a Vulkan renderer option.

## Windows x64 build

Requirements:

- Windows 10/11 x64
- Visual Studio 2022 or newer with the Desktop development with C++ workload
- CMake 3.24+
- Git

~~~powershell
cmake -S . -B build -A x64
cmake --build build --config Release --target BalVOX --parallel
~~~

CMake fetches the pinned Wicked Engine release v0.72.139. The executable and runtime content are placed in build/bin.

## Runtime

Run build/bin/BalVOX.exe. No Godot, Unity, or Unreal installation is needed. The build includes the Wicked Engine runtime shader compiler DLL and the engine's sample terrain scene/content.

## Controls

- W / A / S / D: move camera
- Arrow keys: rotate camera
- Space / Left Ctrl: move vertically
- Left Shift: faster movement

## Rendering

The initial sandbox uses Wicked Engine's PBR renderer and bundled terrain scene, with SSAO, screen-space reflections, bloom, shadows, color grading, temporal anti-aliasing, and sharpening enabled. These effects are deliberately configurable in source because the RX 580 needs sensible performance settings. Hardware ray tracing is not required.

The engine also includes its own terrain, atmosphere, volumetric cloud, ocean, and HLSL shader systems. BalVOX currently uses the engine's built-in rendering path rather than claiming that external shader snippets are already integrated.

## Project layout

- src/main.cpp: Win32 entry point, 3D render path, camera and controls
- CMakeLists.txt: pinned Wicked Engine fetch and Windows x64 build
- .github/workflows/windows.yml: CI build and ZIP packaging
