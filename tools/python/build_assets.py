import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
OUT = ROOT / "generated"
OUT.mkdir(exist_ok=True)
profile = {
    "project": "BalVOX Realistic Simulator",
    "version": "0.2.0",
    "engine": "Godot 4.4",
    "rendering": "Forward+ compatible / GL Compatibility fallback",
    "presets": {
        "low": {"ssao": False, "ssr": False, "volumetric_fog": False},
        "medium": {"ssao": True, "ssr": False, "volumetric_fog": False},
        "high": {"ssao": True, "ssr": True, "volumetric_fog": True},
        "ultra": {"ssao": True, "ssr": True, "volumetric_fog": True}
    }
}
(OUT / "quality_profiles.json").write_text(json.dumps(profile, indent=2), encoding="utf-8")
print(f"Generated simulator profiles at {OUT}")
