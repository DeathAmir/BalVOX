# BalVOX: Missile Sandbox

A small 3D arcade-style sandbox for testing fictional launchers, trajectories, target interactions and stylized impact effects.

## Features
- C++17 and raylib 5.5
- 3D test range, launcher platform and target props
- Game-oriented projectile motion and gravity
- Procedural impact particles
- Animated ground shader and compact telemetry HUD
- Windows x64 build through GitHub Actions

## Controls
- A / D: rotate launcher
- W / S: adjust elevation
- Q / E: adjust arcade power
- Left mouse: launch
- R: reset targets and projectiles
- H: show/hide help
- Tab: pause

This is an entertainment-only game simulation. Its motion model and controls are intentionally fictional and are not intended to model or optimize real-world weapons.

## Build
```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release
```
