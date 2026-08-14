#Requires -Version 5.1
# ============================================================
#  DeepSeek Harness 控制面板（Windows 图形界面版）
#  由 DeepSeek-Harness-GUI.bat 调用，也可在 PowerShell 中直接运行：
#  powershell -ExecutionPolicy Bypass -File .\DeepSeek-Harness-GUI.ps1
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Port = 3080
$Url = "http://127.0.0.1:$Port"

function Test-PortBusy {
    return [bool](Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
}

function Get-ListenerPid {
    $c = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if ($c) { return $c.OwningProcess }
    return $null
}

function Open-Browser { Start-Process $Url | Out-Null }

function Start-Service {
    if (Test-PortBusy) { Open-Browser; Update-Status; return }
    # 另开窗口运行服务，便于查看日志
    Start-Process cmd -ArgumentList '/k', 'npx @deepseek-ai/dsh web' | Out-Null
    $btnStart.Enabled = $false
    $statusLabel.Text = "◐ 正在启动…（首次运行需下载依赖）"
    $count = 0
    $poll = New-Object System.Windows.Forms.Timer
    $poll.Interval = 1000
    $poll.Add_Tick({
        $count++
        if ($count -gt 180) {
            $poll.Stop()
            $statusLabel.Text = "✘ 启动超时，请检查 Node.js 是否安装"
            $btnStart.Enabled = $true
        }
        elseif (Test-PortBusy) {
            $poll.Stop()
            Update-Status
            Open-Browser
        }
    })
    $poll.Start()
}

function Stop-Service {
    $p = Get-ListenerPid
    if ($p) { Stop-Process -Id $p -Force -ErrorAction SilentlyContinue }
    Update-Status
}

function Update-Status {
    if (Test-PortBusy) {
        $statusLabel.Text = "● 运行中"
        $statusLabel.ForeColor = [System.Drawing.Color]::SeaGreen
        $btnStart.Enabled = $false
        $btnStop.Enabled = $true
    }
    else {
        $statusLabel.Text = "○ 已停止"
        $statusLabel.ForeColor = [System.Drawing.Color]::DimGray
        $btnStart.Enabled = $true
        $btnStop.Enabled = $false
    }
}

# ---------- 窗体 ----------
$form = New-Object System.Windows.Forms.Form
$form.Text = "DeepSeek Harness"
$form.Size = New-Object System.Drawing.Size(320, 310)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Size = New-Object System.Drawing.Size(260, 30)
$statusLabel.Location = New-Object System.Drawing.Point(30, 20)
$statusLabel.TextAlign = "MiddleCenter"
$statusLabel.Font = New-Object System.Drawing.Font("Microsoft YaHei", 11)
$form.Controls.Add($statusLabel)

$urlLabel = New-Object System.Windows.Forms.Label
$urlLabel.Size = New-Object System.Drawing.Size(260, 20)
$urlLabel.Location = New-Object System.Drawing.Point(30, 55)
$urlLabel.Text = $Url
$urlLabel.TextAlign = "MiddleCenter"
$urlLabel.ForeColor = [System.Drawing.Color]::DimGray
$form.Controls.Add($urlLabel)

function New-Button {
    param($text, $y, [scriptblock]$action)
    $b = New-Object System.Windows.Forms.Button
    $b.Size = New-Object System.Drawing.Size(180, 34)
    $b.Location = New-Object System.Drawing.Point(70, $y)
    $b.Text = $text
    $b.Font = New-Object System.Drawing.Font("Microsoft YaHei", 10)
    $b.Add_Click($action)
    $form.Controls.Add($b)
    return $b
}

$btnOpen  = New-Button "打开浏览器" 95   { Open-Browser }
$btnStart = New-Button "启动服务"   140  { Start-Service }
$btnStop  = New-Button "停止服务"   185  { Stop-Service }
$btnQuit  = New-Button "退出"       230  { if (Test-PortBusy) { Stop-Service }; $form.Close() }

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 2000
$timer.Add_Tick({ Update-Status })
$timer.Start()

Update-Status
[void]$form.ShowDialog()
