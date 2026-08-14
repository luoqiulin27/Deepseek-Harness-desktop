# DeepSeek Harness 桌面版

一键启动 [DeepSeek Harness](https://github.com/deepseek-ai/dsh)（本地 AI 开发工具，服务地址 `http://127.0.0.1:3080`）的桌面启动器，支持 **macOS** 与 **Windows**。

双击即可运行，自动启动服务并在浏览器中打开界面，无需手敲 `npx @deepseek-ai/dsh web`。

## 功能特性

- ✅ **双击即用**：自动启动服务 → 就绪后自动打开浏览器
- ✅ **macOS 原生应用**：控制面板窗口 + 程序坞图标 + 菜单栏鲸鱼图标，三处入口随时控制
- ✅ **Windows 双版本**：控制台菜单版 + 图形界面版（WinForms）
- ✅ **一键启停**：启动/停止服务、打开浏览器、查看日志，状态实时显示
- ✅ **单实例保护**：重复双击只会调起已有实例，不会重复启动
- ✅ **退出自动清理**：退出/停止时自动结束服务进程，不留后台进程
- ✅ **通用架构**：macOS 版为通用二进制（Intel + Apple Silicon），Windows 版支持 x64

## 文件清单

| 文件 | 平台 | 说明 |
|---|---|---|
| `DeepSeek Harness.dmg` | macOS | 安装镜像（含拖入 Applications 快捷方式） |
| `DeepSeek-Harness.bat` | Windows | 控制台版启动器（双击运行，菜单操作） |
| `DeepSeek-Harness-GUI.bat` | Windows | 图形界面版入口（双击运行） |
| `DeepSeek-Harness-GUI.ps1` | Windows | 图形界面版脚本（被上面的 bat 调用） |
| `README.md` | — | 本说明 |

---

## macOS 使用

### 安装

1. 双击打开 `DeepSeek Harness.dmg`
2. 把 **DeepSeek Harness.app** 拖到 **Applications**（或桌面）
3. 首次打开若提示"无法验证开发者"：右键 App → **打开** → 再点 **打开**
   （应用为本地 ad-hoc 签名，未购买苹果开发者证书；也可执行
   `xattr -dr com.apple.quarantine "/Applications/DeepSeek Harness.app"`）

### 使用

双击 App 启动：

- **控制面板窗口**自动弹出，显示状态：`● 运行中` / `◐ 正在启动…` / `○ 已停止`
- 服务就绪后**自动打开浏览器**
- 应用**常驻程序坞**（白底鲸鱼图标）与**菜单栏**（右上角小鲸鱼）

| 操作 | 方式 |
|---|---|
| 打开浏览器 | 面板按钮 / 菜单 ⌘O |
| 启动/停止服务 | 面板按钮 / 菜单 ⌘S |
| 查看日志 | 菜单 ⌘L（日志：`~/Library/Logs/DeepSeek-Harness.log`） |
| 退出 | 面板/菜单 ⌘Q，或右键 Dock 图标 → 退出（会自动停服务） |
| 重新打开面板 | 点击 Dock 鲸鱼图标 |

> 端口 3080 已有服务时，应用会直接打开浏览器，不会重复启动。

---

## Windows 使用

### 前置要求

- **Windows 10/11**（x64）
- **Node.js LTS**（[nodejs.org](https://nodejs.org) 下载安装，安装时勾选 "Add to PATH"）
- 首次启动需要**联网**（npx 自动下载 dsh 依赖，几十 MB，请耐心等待）

### 方式一：控制台版

双击 `DeepSeek-Harness.bat`，进入菜单：

```
[1] 启动服务并打开浏览器
[2] 打开浏览器
[3] 停止服务
[4] 退出
```

选择 1 后会自动启动服务（另开窗口显示服务日志），就绪后打开浏览器并回到菜单。

### 方式二：图形界面版

双击 `DeepSeek-Harness-GUI.bat`，弹出控制面板窗口：

- 状态显示 + **打开浏览器 / 启动服务 / 停止服务 / 退出** 四个按钮
- 点击"启动服务"后自动轮询等待就绪并打开浏览器
- 退出时自动停止服务

> 提示：PowerShell 执行策略已由 bat 自动绕过（`-ExecutionPolicy Bypass`），无需手动设置。

---

## 常见问题（FAQ）

### Q1：服务启动失败？
- 确认 **Node.js 已安装**且能执行 `npx --version`。
- 查看日志：macOS 在 `~/Library/Logs/DeepSeek-Harness.log`；Windows 看服务窗口输出。

### Q2：提示 "Could not load the sharp module" / "Cannot find the native Koffi module"？
dsh 的原生模块（图像库 sharp、沙箱库 koffi）未正确安装。清除缓存后重试：
```bash
rm -rf ~/.npm/_npx/*/node_modules/@deepseek-ai/dsh
npx @deepseek-ai/dsh web
```
（Windows 为 `rmdir /s /q %USERPROFILE%\.npm\_npx` 后重试）

### Q3：端口 3080 被占用？
应用会自动检测并直接打开浏览器。想强制重启：先 **停止服务**，再 **启动服务**。

### Q4：换一台电脑能用吗？
可以，但需满足：Node.js 已安装、首次运行联网下载依赖。macOS 版为通用二进制（支持 Intel 与 Apple Silicon），最低 macOS 11；Windows 版需 Win10/11 x64。

---

## 技术说明

| 项目 | 说明 |
|---|---|
| 服务命令 | `npx @deepseek-ai/dsh web`（由启动器托管） |
| macOS 实现 | 原生 Swift/AppKit，通用二进制（arm64 + x86_64），最低 macOS 11 |
| Windows 实现 | Batch 控制台版 + PowerShell/WinForms 图形界面版 |
| 架构处理 | 以本机原生架构运行；dsh 双架构原生模块均可加载 |
| 单实例 | 按可执行文件路径检测（macOS），重复双击只调起已有实例 |
| 退出行为 | 退出/停止时结束托管服务，并兜底结束占用 3080 的进程 |
| 工作目录 | macOS：`~/Documents/AI agent`（不存在时回退家目录）；Windows：当前目录 |

## 更新记录

- **v2.1**：跨机器兼容（通用二进制、最低 macOS 11、路径自适应）；新增 Windows 版；文档整合为 README。
- **v2.0**：macOS 原生应用版（控制面板、菜单栏、单实例保护）。
- **v1.x**：macOS 壳脚本版（已废弃）。
