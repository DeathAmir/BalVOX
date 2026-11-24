@echo off
cd /d "%~dp0"
if not exist "Godot_v4.4.1-stable_win64.exe" (
  echo Godot runtime is missing. Please re-download the complete Windows x64 package.
  pause
  exit /b 1
)
start "" "%~dp0Godot_v4.4.1-stable_win64.exe" --path "%~dp0"
