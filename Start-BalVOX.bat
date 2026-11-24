@echo off
cd /d "%~dp0"
if not exist "Godot.exe" (
  echo Godot runtime is missing. Please re-download the complete Windows x64 package.
  pause
  exit /b 1
)
start "" "%~dp0Godot.exe" --path "%~dp0"
