# BalVOX Realistic Simulator

A Windows x64 3D test-range sandbox built with Godot 4.4.1. The project no longer uses Raylib. The Windows package includes the Godot runtime, so the user does not need to install a game engine.

## Technology

- Godot 4.4.1: 3D scene, camera, gameplay, particles, input and physics.
- GDScript: simulator runtime and quality presets.
- C++17: native calculation library used by the desktop configurator.
- C# / .NET 8: Windows graphics and simulation settings utility.
- Python 3: build-time generation of quality profile metadata.
- Rust: settings/telemetry validation utility.
- Godot Shader Language: material and rendering pipeline.

## Windows x64

Download the Windows x64 package from GitHub Releases, extract it, and run `Start-BalVOX.bat`. No Godot installation is required.

The C# configurator is in `Configurator`. The Rust validator and generated graphics profiles are in `Tools`.

## Controls

- WASD: move camera
- Mouse: look around
- Space: launch a fictional test projectile
- Q / E: adjust test angle
- +/-: adjust simulation power
- Mouse wheel: adjust camera movement speed
- F1: toggle help
- F2: cycle Low / Medium / High / Ultra
- F3: settings panel
- R: reset range
- Tab: pause
- Esc: release/capture mouse

## Graphics

Four quality presets are provided. Low disables expensive screen-space effects; Medium enables ambient occlusion; High and Ultra enable additional reflections, volumetric fog and stronger post-processing. The Forward+ renderer is enabled for dynamic lighting, ambient occlusion, screen-space reflections and volumetric fog. The RX 580 is the target baseline; Low and Medium presets reduce expensive effects. If a GPU driver cannot initialize Vulkan, a future compatibility build can be added.

## Build

The GitHub Actions workflow downloads the official Godot 4.4.1 Windows runtime, validates the project headlessly, builds the C++ library, Rust utility and C# configurator, then packages everything into a self-contained Windows x64 ZIP.

This is an entertainment-focused fictional sandbox. Its test projectiles and physics are game simulation, not a real-world engineering or weapons-design tool.
