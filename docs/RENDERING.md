# BalVOX rendering notes

Wicked Engine is pinned to v0.72.139. The runtime uses its HLSL renderer and the bundled terrain scene.

Useful upstream implementation references:

- Terrain blending and terrain shader interop: WickedEngine/shaders/ShaderInterop_Terrain.h
- Atmosphere and volumetric cloud parameters: WickedEngine/shaders/ShaderInterop_Weather.h
- Renderer post-processing controls: WickedEngine/wiRenderPath3D.h
- Runtime shader compiler: WickedEngine/wiShaderCompiler.h

BalVOX's shaders/procedural_surface.hlsli is a reusable procedural shading include containing hash noise, 3D value noise, fBm and triplanar weighting. It is a source module for later custom-material integration; it is not currently injected into Wicked Engine's built-in terrain material.

Avoid enabling hardware ray tracing on RX 580. Start with SSAO, SSR, temporal AA, bloom and conventional shadow maps. If performance is low, disable SSR first, reduce AO samples, and then lower internal render resolution.
