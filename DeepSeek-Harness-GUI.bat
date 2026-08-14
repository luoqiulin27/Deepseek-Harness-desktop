@echo off
chcp 65001 >nul
title DeepSeek Harness
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0DeepSeek-Harness-GUI.ps1"
