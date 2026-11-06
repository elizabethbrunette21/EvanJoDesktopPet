# EvanJoDesktopPet for Windows

English | [简体中文](#简体中文)

Native .NET 8 / WPF desktop pet with bundled, local-only character assets.

## Current behavior

- Transparent, borderless, topmost, non-activating window; drag and right-click controls.
- Five layered poses: Idle nod/petting sparkles; Happy jump/flower burst;
  Loading spinner/scrolling text; Speechless leaf; Brainwave glasses/bubble/dots.
- A fixed 240 x 184 DIP character surface reserves room for effects. Character
  bodies are approximately 130.7 DIP tall, with the feet at y=176 across poses.
- Happy's seven flowers use the original atlas masks and appear at the larger
  requested scale; the original thin jump lines appear below the feet.
- Clicking Loading plays Brainwave; clicking any other pose plays Happy.
  Dragging begins after the pointer moves beyond the click threshold. Selecting
  the same pose again replays its animation. Hidden renderers stop their timelines.
- Loading, Thinking and Sleepy honor the Windows client-area animation setting.
- Static fallback images remain available when a layer set cannot be loaded.

Automatic mode cycles through Idle and weighted temporary poses. Character
switching, roaming and saved position remain separate work.

## Download and install on Windows

[Download `EvanJoDesktopPet-Windows-x64.zip`](https://github.com/elizabethbrunette21/EvanJoDesktopPet/releases/download/windows-v0.1.0-preview.2/EvanJoDesktopPet-Windows-x64.zip) and extract it.
Double-click `Install.cmd` to copy the self-contained app into your user profile,
create the **Evan Jo Desktop Pet** desktop shortcut, and open the pet. No .NET
installation or administrator access is required. You can also run
`EvanJoDesktopPet.Windows.exe` directly from the extracted folder without
installing it. To update an installed copy, quit the pet from its right-click
menu before running the new `Install.cmd`.

The ZIP is an unsigned preview build. Windows may show a publisher warning.

## Build and run on Windows

Requires Windows 10 or later and the .NET 8 SDK. From this directory:

```powershell
dotnet build .\EvanJoDesktopPet.Windows.sln --configuration Debug
dotnet run --project .\src\EvanJoDesktopPet.Windows\EvanJoDesktopPet.Windows.csproj --no-build
```

Build the ZIP locally with:

```powershell
.\scripts\Publish-Windows.ps1
```

The script publishes a self-contained Windows x64 executable and writes
`dist\EvanJoDesktopPet-Windows-x64.zip`. Pushing a `windows-v*` tag runs the
Windows release workflow, which builds and uploads the ZIP to GitHub Releases.
`dist` is excluded from Git because release binaries are distributed as assets.

## Focused verification

The Windows x64 self-contained Release publish and targeted behavior checks pass.
The installer creates a desktop shortcut pointing to the installed executable.

The asset/layout regression check requires Python 3 and Pillow:

```powershell
python .\tests\check_visual_layout.py
```

It measures the actual transparent image bounds, compares Idle/Happy heights and
feet, checks all flower paths against the surface, and validates the new layers.

On Windows, select each pose from the context menu, select Happy twice, and
switch out of Loading while its text is moving. Check that the body stays at the
same scale and baseline, flowers are fully visible, and old effects stop. Repeat
at 100%, 150% and 200% display scale. Runtime visual approval remains required.

The Swift/macOS implementation remains a read-only visual reference. This
Windows project bundles its own copies of approved runtime PNGs and does not
require the macOS source tree to build or run.

## 简体中文

### 下载与安装

[下载 Windows x64 ZIP 安装包](https://github.com/elizabethbrunette21/EvanJoDesktopPet/releases/download/windows-v0.1.0-preview.2/EvanJoDesktopPet-Windows-x64.zip)，解压后双击 `Install.cmd`。安装脚本会将独立运行的程序复制到当前用户目录，创建 **Evan Jo Desktop Pet** 桌面快捷方式，并打开宠物。需要 Windows 10 或更高版本；无需另装 .NET 或使用管理员权限。更新前请从右键菜单退出旧版。预览版尚未签名，Windows 可能显示发布者警告。

### 使用与构建

右键菜单支持中文和英文，跟随系统界面语言；其他语言使用英文。点击 Loading 会进入“灵光一现”，点击其他状态会进入 Happy。移动鼠标超过点击阈值才会开始拖动。自动模式在各状态间切换，固定模式保留所选状态。开发者可用上面的 PowerShell 命令构建，并运行 `scripts/Publish-Windows.ps1` 生成发布 ZIP。
