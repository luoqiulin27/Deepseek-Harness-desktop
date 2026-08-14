@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title DeepSeek Harness

set "PORT=3080"
set "URL=http://127.0.0.1:%PORT%"

:menu
cls
echo ============================================
echo    DeepSeek Harness  -  Windows 控制台版
echo    服务地址: %URL%
echo ============================================
netstat -ano | findstr /r ":%PORT% .*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo   状态: [● 运行中]
) else (
    echo   状态: [○ 已停止]
)
echo --------------------------------------------
echo   [1] 启动服务并打开浏览器
echo   [2] 打开浏览器
echo   [3] 停止服务
echo   [4] 退出
echo --------------------------------------------
choice /c 1234 /n /m "请选择: "
if errorlevel 4 exit /b
if errorlevel 3 goto stop
if errorlevel 2 goto open
if errorlevel 1 goto start

:start
netstat -ano | findstr /r ":%PORT% .*LISTENING" >nul 2>&1
if not errorlevel 1 (
    echo 服务已在运行，直接打开浏览器...
    start "" "%URL%"
    goto menu
)
echo 正在启动: npx @deepseek-ai/dsh web
echo 首次运行需要下载依赖，请耐心等待...
start "DeepSeek Harness Server" cmd /k "npx @deepseek-ai/dsh web"
echo 等待服务就绪...
for /l %%i in (1,1,180) do (
    curl -s -o nul --max-time 2 "%URL%" >nul 2>&1
    if not errorlevel 1 (
        echo 服务已就绪，打开浏览器...
        start "" "%URL%"
        goto menu
    )
    timeout /t 1 /nobreak >nul
)
echo 启动超时：请确认已安装 Node.js，并查看服务窗口中的报错信息。
pause
goto menu

:open
start "" "%URL%"
goto menu

:stop
netstat -ano | findstr /r ":%PORT% .*LISTENING" >nul 2>&1
if errorlevel 1 (
    echo 当前没有服务在运行。
    pause
    goto menu
)
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /r ":%PORT% .*LISTENING"') do (
    taskkill /f /pid %%p >nul 2>&1
)
echo 服务已停止。
pause
goto menu
